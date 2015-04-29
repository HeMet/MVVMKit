//
//  ViewModel.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 17.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import ReactiveCocoa
import LlamaKit
import MVVMKit

class ViewModel {
    static let inactiveThrottleInterval: NSTimeInterval = 1
    
    //todo: to remove reference to UIKit it's better to let Router init this property
    var router: Router {
        return (UIApplication.sharedApplication().delegate! as! UIMVVMApplication).router
    }
    
    var active = MutableProperty<Bool>(false)
    
    lazy var didBecomeActiveSignal: SignalProducer<ViewModel, NoError> = {
        return self.active.producer |> filter { $0 } |> map { _ in self }
    }()
    
    lazy var didBecomeInactiveSignal: SignalProducer<ViewModel, NoError> = {
        return self.active.producer |> filter { !$0 } |> map { _ in self }
    }()
    
    func forwardSignalWhileActive<T, E>(signal: Signal<T, E>) -> Signal<T, E> {
        return Signal { observer in
            let compositeDisposable = CompositeDisposable()
            
            var signalDisposable: Disposable?
            var signalDisposableHandle: CompositeDisposable.DisposableHandle?
            
            let activeDisposable = self.active.producer.start(Signal.Observer { event in
                switch event {
                case .Next(let isActive):
                    if (isActive.unbox) {
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
                    observer.put(Event<T, E>.Completed)
                case .Interrupted:
                    observer.put(Event<T, E>.Interrupted)
                default:
                    break
                }
            })
            
            compositeDisposable.addDisposable(activeDisposable)

            return compositeDisposable
        }
    }
    
    func forwardSignalWhileActive<T, E>(signal: SignalProducer<T, E>) -> SignalProducer<T, E> {
        return SignalProducer { observer, compositeDisposable in
            var signalDisposable: Disposable?
            var signalDisposableHandle: CompositeDisposable.DisposableHandle?
            
            let activeDisposable = self.active.producer.start(Signal.Observer { event in
                switch event {
                case .Next(let isActive):
                    if (isActive.unbox) {
                        // forward event from input signal to output
                        signalDisposable = signal.start(Signal.Observer { event in
                            switch event {
                            case .Interrupted:
                                // signal should be paused, not interrupted
                                break
                            default:
                                observer.put(event)
                            }
                        })
                        
                        signalDisposableHandle = compositeDisposable.addDisposable(signalDisposable)
                    } else {
                        // sends Interrupted to observer
                        signalDisposable?.dispose()
                        signalDisposableHandle?.remove()
                        signalDisposable = nil
                        signalDisposableHandle = nil
                    }
                case .Completed:
                    observer.put(Event<T, E>.Completed)
                case .Interrupted:
                    observer.put(Event<T, E>.Interrupted)
                default:
                    break
                }
            })
            
            compositeDisposable.addDisposable(activeDisposable)
        }
    }
    
    /*
    - (RACSignal *)throttleSignalWhileInactive:(RACSignal *)signal {
    NSParameterAssert(signal != nil);
    
    signal = [signal replayLast];
    
    return [[[[[RACObserve(self, active)
    takeUntil:[signal ignoreValues]]
    combineLatestWith:signal]
    throttle:RVMViewModelInactiveThrottleInterval valuesPassingTest:^ BOOL (RACTuple *xs) {
    BOOL active = [xs.first boolValue];
    return !active;
    }]
    reduceEach:^(NSNumber *active, id value) {
    return value;
    }]
    setNameWithFormat:@"%@ -throttleSignalWhileInactive: %@", self, signal];
    }
    */
    func throttleSignalWhileInactive<T, E>(signal: SignalProducer<T, E>) -> SignalProducer<T, E> {
        return signal |> throttleWhile(self.active.producer |> map { !$0 })
    }
}