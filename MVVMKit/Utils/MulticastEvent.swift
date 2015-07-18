//
//  MulticastEvent.swift
//  MVVMKit
//
//  Created by Евгений Губин on 20.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public struct MulticastEvent<ContextType: AnyObject, ArgsType> {
    typealias Listener = (ContextType, ArgsType) -> ()
    
    // there is no good way in swift to compare two closures (it's intentional)
    var listeners = [String: Listener]()
    weak var context: ContextType!
    
    public init(context: ContextType) {
        self.context = context
    }
    
    public mutating func register(tag: String, listener: Listener) {
        listeners[tag] = listener
    }
    
    public mutating func unregister(tag: String) {
        listeners.removeValueForKey(tag)
    }
    
    public func fire(args: ArgsType) {
        if let ctx = context {
            for (tag, listener) in listeners {
                listener(context, args)
            }
        }
    }
}

infix operator += { associativity left precedence 90 }
infix operator -= { associativity left precedence 90 }

public  func += <CtxType, ArgsType>(var mce: MulticastEvent<CtxType, ArgsType>, ri: (String, (CtxType, ArgsType) -> ())) {
    mce.register(ri.0, listener: ri.1)
}

public  func -= <CtxType, ArgsType>(var mce: MulticastEvent<CtxType, ArgsType>, tag: String) {
    mce.unregister(tag)
}