//
//  ObservableOrderedDictionary.swift
//  MVVMKit
//
//  Created by Евгений Губин on 19.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

//public final class ObservableOrderedDictionary<KeyType: Hashable, ValueType>: BaseObservableOrderedDictionary<KeyType, ValueType>, ObservableCollection, MutableCollectionType {
//    public typealias ItemType = (KeyType, ValueType)
//    public typealias RangeChangedEvent = MulticastEvent<ObservableOrderedDictionary, ([ItemType], Range<Int>)>
//    public typealias UpdatePhaseEvent = MulticastEvent<ObservableOrderedDictionary, UpdatePhase>
//    
//    public var onDidInsertRange: RangeChangedEvent!
//    public var onDidRemoveRange: RangeChangedEvent!
//    public var onDidChangeRange: RangeChangedEvent!
//    
//    public var onBatchUpdate: UpdatePhaseEvent!
//
//    public required convenience init(data: [ItemType]) {
//        self.init()
//        
//        innerDictionary = OrderedDictionary(pairs: data)
//    }
//    
//    public override init() {
//        super.init()
//        
//        onDidInsertRange = RangeChangedEvent(context: self)
//        onDidRemoveRange = RangeChangedEvent(context: self)
//        onDidChangeRange = RangeChangedEvent(context: self)
//        onBatchUpdate = UpdatePhaseEvent(context: self)
//    }
//    
//    override func fireInsert(items: [ItemType], _ idxs: Range<Int>) {
//        onDidInsertRange.fire(items, idxs)
//    }
//    
//    override func fireRemove(items: [ItemType], _ idxs: Range<Int>) {
//        onDidRemoveRange.fire(items, idxs)
//    }
//    
//    override func fireChange(items: [ItemType], _ idxs: Range<Int>) {
//        onDidChangeRange.fire(items, idxs)
//    }
//    
//    override func fireBatchUpdate(phase: UpdatePhase) {
//        onBatchUpdate.fire(phase)
//    }
//}

public final class ObservableOrderedDictionary<KeyType: Hashable, ValueType>: OrderedDictionaryWrapper, ObservableCollection {
    public typealias _Self = ObservableOrderedDictionary<KeyType, ValueType>
    public typealias Base = OrderedDictionary<KeyType, ValueType>
    public typealias EventType = MulticastEvent<_Self, Items<_Self.Generator.Element>>
    public typealias BatchUpdateEventType = MulticastEvent<_Self, UpdatePhase>
    
    public var innerCollection: Base = [:]
    
    public var onDidInsertItems: EventType!
    public var onDidRemoveItems: EventType!
    public var onDidChangeItems: EventType!
    
    public var onBatchUpdate: BatchUpdateEventType!
    
    public init() {
        
        attachToInnerCollection()
    }
    
    public init(dictionaryLiteral elements: Base.Element...) {
        innerCollection = OrderedDictionary(pairs: elements)
        initEvents()
        attachToInnerCollection()
    }
    
    func attachToInnerCollection() {
        innerCollection.onMove = handleInnerCollectionMove
        innerCollection.onUpdate = handleInnerCollectionUpdate
        innerCollection.onRemove = handleInnerCollectionRemove
    }
    
    public subscript(position: Base.Index) -> Base.Element {
        get {
            return innerCollection[position]
        }
        set {
            oc_setValue(newValue, atPosition: position)
        }
    }
    
    public func replaceRange<C : CollectionType where C.Generator.Element == Base.Generator.Element>(subRange: Range<Base.Index>, with newElements: C) {
        oc_replaceRange(subRange) {
            innerCollection.replaceRange(subRange, with: newElements)
        }
    }
    
    subscript(key: KeyType) -> ValueType? {
        get {
            return innerCollection[key]
        }
        set {
            innerCollection[key] = newValue
        }
    }
    
    var keys: [KeyType] {
        return innerCollection.keys
    }
    
    
    func updateValue(value: ValueType, forKey key: KeyType) -> ValueType? {
        return innerCollection.updateValue(value, forKey: key)
    }
    
    public func removeValueForKey(key: KeyType) {
        innerCollection.removeValueForKey(key)
    }
    
    public func indexOfKey(key: KeyType) -> Int? {
        return innerCollection.indexOfKey(key)
    }
    
    public func getValueForKey(key: KeyType) -> ValueType? {
        return innerCollection[key]
    }
    
    func handleInnerCollectionUpdate(index: Index) {
        fireChangeItem(index)
    }
    
    func handleInnerCollectionMove(from: Index?, to: Index) {
        let element = innerCollection[to]
        if let from = from {
            fireRemoveItem(element, atIndex: from)
        }
        fireInsertItem(to)
    }
    
    func handleInnerCollectionRemove(index: Index, element: Base.Element) {
        fireRemoveItem(element, atIndex: index)
    }
}