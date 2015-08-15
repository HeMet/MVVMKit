//
//  RACExtensions.swift
//  MVVMKit
//
//  Created by Eugene Gubin on 27.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension SignalType {
    public func ignoreValues() -> Signal<(), E> {
        return Signal<(), E> { observer in
            return self.observe ({ event in
                switch (event) {
                case .Error(let error):
                    sendError(observer, error)
                case .Interrupted:
                    sendInterrupted(observer)
                case .Completed:
                    sendCompleted(observer)
                default:
                    break
                }
            })
        }
    }
    
    public func ignoreErrors() -> Signal<T, NoError> {
        return Signal<T, NoError> { observer in
            return self.observe ({ event in
                switch (event) {
                case .Next(let value):
                    sendNext(observer, value)
                case .Interrupted:
                    sendInterrupted(observer)
                case .Completed:
                    sendCompleted(observer)
                default:
                    break
                }
            })
        }
    }
    
    public func throttle(interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType, passingTest: (T) -> Bool) -> Signal<T, E> {
        precondition(interval >= 0)
        
        return Signal { observer in
            let state: Atomic<ThrottleState<T>> = Atomic(ThrottleState())
            let schedulerDisposable = SerialDisposable()
            
            let disposable = CompositeDisposable()
            disposable.addDisposable(schedulerDisposable)
            
            disposable += self.observe({ event in
                switch event {
                case let .Next(value):
                    if passingTest(value) {
                        let (_, scheduleDate) = state.modify { (var state) -> (ThrottleState<T>, NSDate) in
                            state.pendingValue = value
                            
                            let proposedScheduleDate = state.previousDate?.dateByAddingTimeInterval(interval) ?? scheduler.currentDate
                            let scheduleDate = proposedScheduleDate.laterDate(scheduler.currentDate)
                            return (state, scheduleDate)
                        }
                        
                        schedulerDisposable.innerDisposable = scheduler.scheduleAfter(scheduleDate) {
                            let (_, pendingValue) = state.modify { (var state) -> (ThrottleState<T>, T?) in
                                let value = state.pendingValue
                                if value != nil {
                                    state.pendingValue = nil
                                    state.previousDate = scheduleDate
                                }
                                
                                return (state, value)
                            }
                            
                            if let pendingValue = pendingValue {
                                sendNext(observer, pendingValue)
                            }
                        }
                    } else {
                        state.modify { (var state) -> (ThrottleState<T>, NSDate) in
                            state.pendingValue = nil
                            state.previousDate = scheduler.currentDate
                            return (state, scheduler.currentDate)
                        }
                        
                        schedulerDisposable.innerDisposable = scheduler.schedule {
                            sendNext(observer, value)
                        }
                    }
                    
                default:
                    schedulerDisposable.innerDisposable = scheduler.schedule {
                        observer(event)
                    }
                }
            })
            
            return disposable
        }
    }
    
    public func forwardWhile(conditionSignal: Signal<Bool, NoError>) -> Signal<T, E> {
        return Signal { observer in
            let compositeDisposable = CompositeDisposable()
            
            var signalDisposable: Disposable?
            var signalDisposableHandle: CompositeDisposable.DisposableHandle?
            
            compositeDisposable += conditionSignal.observe({ event in
                switch event {
                case .Next(let isActive):
                    if (isActive) {
                        // forward event from input signal to output
                        signalDisposable = self.observe(observer)
                        signalDisposableHandle = compositeDisposable.addDisposable(signalDisposable)
                    } else {
                        signalDisposable?.dispose()
                        signalDisposableHandle?.remove()
                        signalDisposable = nil
                        signalDisposableHandle = nil
                    }
                case .Completed:
                    sendCompleted(observer)
                case .Interrupted:
                    sendInterrupted(observer)
                default:
                    break
                }
            })
            
            return compositeDisposable
        }
    }
}

private struct ThrottleState<T> {
    var previousDate: NSDate? = nil
    var pendingValue: T? = nil
}

extension SignalProducerType {
    public func throttle(interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType, passingTest: (T) -> Bool) -> SignalProducer<T, E> {
        return lift { $0.throttle(interval, onScheduler: scheduler, passingTest: passingTest) }
    }
    
    public func forwardWhile(conditionProducer: SignalProducer<Bool, NoError>) -> SignalProducer<T, E> {
        return lift(_forwardWhile)(conditionProducer)
    }
}

private func _forwardWhile<T, E>(conditionSignal: Signal<Bool, NoError>) -> Signal<T, E> -> Signal<T, E> {
    return { $0.forwardWhile(conditionSignal) }
}

internal final class Atomic<T> {
    private var spinlock = OS_SPINLOCK_INIT
    private var _value: T
    
    /// Atomically gets or sets the value of the variable.
    var value: T {
        get {
            lock()
            let v = _value
            unlock()
            
            return v
        }
        
        set(newValue) {
            lock()
            _value = newValue
            unlock()
        }
    }
    
    /// Initializes the variable with the given initial value.
    init(_ value: T) {
        _value = value
    }
    
    private func lock() {
        withUnsafeMutablePointer(&spinlock, OSSpinLockLock)
    }
    
    private func unlock() {
        withUnsafeMutablePointer(&spinlock, OSSpinLockUnlock)
    }
    
    /// Atomically replaces the contents of the variable.
    ///
    /// Returns the old value.
    func swap(newValue: T) -> T {
        return modify { _ in newValue }
    }
    
    /// Atomically modifies the variable.
    ///
    /// Returns the old value.
    func modify(@noescape action: T -> T) -> T {
        let (oldValue, _) = modify { oldValue in (action(oldValue), 0) }
        return oldValue
    }
    
    /// Atomically modifies the variable.
    ///
    /// Returns the old value, plus arbitrary user-defined data.
    func modify<U>(@noescape action: T -> (T, U)) -> (T, U) {
        lock()
        let oldValue: T = _value
        let (newValue, data) = action(_value)
        _value = newValue
        unlock()
        
        return (oldValue, data)
    }
    
    /// Atomically performs an arbitrary action using the current value of the
    /// variable.
    ///
    /// Returns the result of the action.
    func withValue<U>(@noescape action: T -> U) -> U {
        lock()
        let result = action(_value)
        unlock()
        
        return result
    }
}