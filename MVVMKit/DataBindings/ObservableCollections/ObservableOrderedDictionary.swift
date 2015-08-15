//
//  ObservableOrderedDictionary.swift
//  MVVMKit
//
//  Created by Евгений Губин on 19.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public final class ObservableOrderedDictionary<KeyType: Hashable, ValueType>: BaseObservableOrderedDictionary<KeyType, ValueType>, ObservableCollection {
    public typealias ItemType = (KeyType, ValueType)
    public typealias RangeChangedEvent = MulticastEvent<ObservableOrderedDictionary, ([ItemType], Range<Int>)>
    public typealias UpdatePhaseEvent = MulticastEvent<ObservableOrderedDictionary, UpdatePhase>
    
    public var onDidInsertRange: RangeChangedEvent!
    public var onDidRemoveRange: RangeChangedEvent!
    public var onDidChangeRange: RangeChangedEvent!
    
    public var onBatchUpdate: UpdatePhaseEvent!

    public required convenience init(data: [ItemType]) {
        self.init()
        
        innerDictionary = OrderedDictionary(pairs: data)
    }
    
    public override init() {
        super.init()
        
        onDidInsertRange = RangeChangedEvent(context: self)
        onDidRemoveRange = RangeChangedEvent(context: self)
        onDidChangeRange = RangeChangedEvent(context: self)
        onBatchUpdate = UpdatePhaseEvent(context: self)
    }
    
    override func fireInsert(items: [ItemType], _ idxs: Range<Int>) {
        onDidInsertRange.fire(items, idxs)
    }
    
    override func fireRemove(items: [ItemType], _ idxs: Range<Int>) {
        onDidRemoveRange.fire(items, idxs)
    }
    
    override func fireChange(items: [ItemType], _ idxs: Range<Int>) {
        onDidChangeRange.fire(items, idxs)
    }
    
    override func fireBatchUpdate(phase: UpdatePhase) {
        onBatchUpdate.fire(phase)
    }
}