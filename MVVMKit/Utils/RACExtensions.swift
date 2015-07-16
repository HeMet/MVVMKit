//
//  RACExtensions.swift
//  MVVMKit
//
//  Created by Eugene Gubin on 27.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import ReactiveCocoa

public func ignoreValues<T, E>(signal: Signal<T, E>) -> Signal<(), E> {
    return Signal<(), E> { observer in
        return signal.observe (Signal.Observer { event in
            switch (event) {
            case .Error(let error):
                sendError(observer, error.value)
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

public func ignoreErrors<T, E>(signal: Signal<T, E>) -> Signal<T, NoError> {
    return Signal<T, NoError> { observer in
        return signal.observe (Signal.Observer { event in
            switch (event) {
            case .Next(let value):
                sendNext(observer, value.value)
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

public func throttle<T, E>(interval: NSTimeInterval, onScheduler scheduler: DateSchedulerType, passingTest: (T) -> Bool) -> Signal<T, E> -> Signal<T, E> {
    precondition(interval >= 0)
    
    return { signal in
        return Signal { observer in
            let state: Atomic<ThrottleState<T>> = Atomic(ThrottleState())
            let schedulerDisposable = SerialDisposable()
            
            let disposable = CompositeDisposable()
            disposable.addDisposable(schedulerDisposable)
            
            let signalDisposable = signal.observe(SinkOf { event in
                switch event {
                case let .Next(value):
                    if passingTest(value.value) {
                        let (_, scheduleDate) = state.modify { (var state) -> (ThrottleState<T>, NSDate) in
                            state.pendingValue = value.value
                            
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
                            sendNext(observer, value.value)
                        }
                    }
                    
                default:
                    schedulerDisposable.innerDisposable = scheduler.schedule {
                        observer.put(event)
                    }
                }
                })
            
            disposable.addDisposable(signalDisposable)
            return disposable
        }
    }
}

private struct ThrottleState<T> {
    var previousDate: NSDate? = nil
    var pendingValue: T? = nil
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

public func forwardWhile<T, E>(conditionSignal: Signal<Bool, NoError>)(signal: Signal<T, E>) -> Signal<T, E> {
    return Signal { observer in
        let compositeDisposable = CompositeDisposable()
        
        var signalDisposable: Disposable?
        var signalDisposableHandle: CompositeDisposable.DisposableHandle?
        
        let activeDisposable = conditionSignal.observe(SinkOf { event in
            switch event {
            case .Next(let isActive):
                if (isActive.value) {
                    // forward event from input signal to output
                    signalDisposable = signal.observe(observer)
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
        
        compositeDisposable.addDisposable(activeDisposable)
        
        return compositeDisposable
    }
}

public func forwardWhile<T, E>(conditionProducer: SignalProducer<Bool, NoError>)(producer: SignalProducer<T, E>) -> SignalProducer<T, E> {
    return producer.lift(forwardWhile)(conditionProducer)
}

public func throttle<T, E>(# interval: NSTimeInterval)(_while: Signal<Bool, NoError>)(signal: Signal<T, E>) -> Signal<T, E> {
    let signalCompletes = signal |> ignoreValues |> ignoreErrors
    // while signal is not completed
    let result = _while |> takeUntil(signalCompletes) |> promoteErrors(E.self)
    // combine latest value from signal with active value
    let result2 = combineLatestWith(result)(signal: signal)
    // throttle it when not active and forward it immediately in other case
    let result3 = result2 |> throttle(interval, onScheduler: QueueScheduler()) { !$0.1 } |> map { $0.0 }
    
    return result3
}

public func throttle<T, E>(# interval: NSTimeInterval)(_while: SignalProducer<Bool, NoError>)(producer: SignalProducer<T, E>) -> SignalProducer<T, E> {
    return producer.lift(throttle(interval: interval))(_while)
}