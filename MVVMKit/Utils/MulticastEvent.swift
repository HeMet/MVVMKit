//
//  MulticastEvent.swift
//  MVVMKit
//
//  Created by Евгений Губин on 20.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public struct MulticastEvent<ContextType: AnyObject, ArgsType> {
    public typealias Listener = (ContextType, ArgsType) -> ()
    
    // there is no good way in swift to compare two closures (it's intentional)
    var listeners = [String: Listener]()
    weak var context: ContextType!
    
    public init(context: ContextType) {
        self.context = context
    }
    
    public mutating func register(_ tag: String, listener: Listener) {
        listeners[tag] = listener
    }
    
    public mutating func unregister(_ tag: String) {
        listeners.removeValue(forKey: tag)
    }
    
    public func fire(_ args: ArgsType) {
        if let ctx = context {
            for (_, listener) in listeners {
                listener(ctx, args)
            }
        }
    }
}

infix operator += { associativity left precedence 90 }
infix operator -= { associativity left precedence 90 }

public  func += <CtxType, ArgsType>(mce: MulticastEvent<CtxType, ArgsType>, ri: (String, (CtxType, ArgsType) -> ())) {
    var mce = mce
    mce.register(ri.0, listener: ri.1)
}

public  func -= <CtxType, ArgsType>(mce: MulticastEvent<CtxType, ArgsType>, tag: String) {
    var mce = mce
    mce.unregister(tag)
}
