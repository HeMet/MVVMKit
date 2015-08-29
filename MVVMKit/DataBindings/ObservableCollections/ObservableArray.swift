//
//  ObservableArray.swift
//  MVVMKit
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public final class ObservableArray<T>: ArrayWrapper, ObservableCollection {
    public typealias _Self = ObservableArray<T>
    
    public typealias Base = [T]
    
    public typealias EventType = MulticastEvent<_Self, Items<T>>
    public typealias BatchUpdateEventType = MulticastEvent<_Self, UpdatePhase>
    
    public var innerCollection: [T] = []
    
    public var onDidInsertItems: EventType!
    public var onDidRemoveItems: EventType!
    public var onDidChangeItems: EventType!
    
    public var onBatchUpdate: BatchUpdateEventType!
    
    public required init() {
        initEvents()
    }
    
    public convenience init(data: Base) {
        self.init()
        innerCollection = data
    }
    
    public subscript(position: Int) -> T {
        get {
            return innerCollection[position]
        }
        set {
            oc_setValue(newValue, atPosition: position)
        }
    }
    
    public subscript(bounds: Range<Int>) -> Base.SubSequence {
        get {
            return innerCollection[bounds]
        }
        set {
            oc_replaceRange(bounds) {
                innerCollection[bounds] = newValue
            }
        }
    }
}
