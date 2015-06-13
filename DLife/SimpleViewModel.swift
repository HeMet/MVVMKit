//
//  SimpleViewModel.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 15.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import ReactiveCocoa
import MVVMKit

class SimpleViewModel : BaseViewModel {
    var data: String
    
    var value = MutableProperty<Int>(0)
    var textProperty = MutableProperty<String>("string")
    
    init (s: String) {
        data = s
    }
    
    var _increment: Action<AnyObject?, Int, NoError>?
    var increment: Action<AnyObject?, Int, NoError> {
        if _increment == nil {
            _increment = Action<AnyObject?, Int, NoError> { input in
                return SignalProducer<Int, NoError> { observer, disposable in
//                    self.value.value++
//                    sendNext(observer, self.value.value)
                    let svm = SimpleViewModel(s: "child")
                    GoTo.next(sender: self)(svm)
                    
                    NSTimer.schedule(delay: 3) { timer in
                        goBack(svm)
                    }
                    
                    sendCompleted(observer)
                }
            }
        }
        return _increment!
    }
}