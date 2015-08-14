//
//  DynamicPropertyTyped.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 17.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation
import ReactiveCocoa

//        let toMap = { (s: String) -> AnyObject? in return s }
//        let fromMap = { (o: AnyObject?) -> String in return o as! String }
//        var textProperty2 = DynamicPropertyTyped<String>(object: self.subviewHook, keyPath: "text", mapTo: toMap, mapFrom: fromMap)

public final class DynamicPropertyTyped<T>: RACDynamicPropertySuperclass, MutablePropertyType {
    public typealias Value = T
    
    public typealias MapToClosure = (T) -> AnyObject?
    public typealias MapFromClosure = (AnyObject?) -> T
    
    private weak var object: NSObject?
    private let keyPath: String
    
    private let mapTo: MapToClosure
    private let mapFrom: MapFromClosure
    
    /// The current value of the property, as read and written using Key-Value
    /// Coding.
    public var value: T {
        get {
            let temp: AnyObject? = object?.valueForKeyPath(keyPath)
            return mapFrom(temp)
        }
        
        set(newValue) {
            let temp: AnyObject? = mapTo(newValue)
            object?.setValue(temp, forKeyPath: keyPath)
        }
    }
    
    /// A producer that will create a Key-Value Observer for the given object,
    /// send its initial value then all changes over time, and then complete
    /// when the observed object has deallocated.
    ///
    /// By definition, this only works if the object given to init() is
    /// KVO-compliant. Most UI controls are not!
    public var producer: SignalProducer<Value, NoError> {
        if let object = object {
            return object.rac_valuesForKeyPath(keyPath, observer: nil).toSignalProducer() |> map(mapFrom)
                // Errors aren't possible, but the compiler doesn't know that.
                |> catch { error in
                    assert(false, "Received unexpected error from KVO signal: \(error)")
                    return .empty
            }
        } else {
            return .empty
        }
    }
    
    /// Initializes a property that will observe and set the given key path of
    /// the given object. `object` must support weak references!
    public init(object: NSObject?, keyPath: String, mapTo: MapToClosure, mapFrom: MapFromClosure) {
        self.object = object
        self.keyPath = keyPath
        
        self.mapTo = mapTo
        self.mapFrom = mapFrom
        
        /// DynamicProperty stay alive as long as object is alive.
        /// This is made possible by strong reference cycles.
        super.init()
        object?.rac_willDeallocSignal()?.toSignalProducer().start(completed: { self })
    }
}
