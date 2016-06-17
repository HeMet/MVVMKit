//
//  ObservableOrderedDictionary.swift
//  MVVMKit
//
//  Created by Евгений Губин on 19.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public final class ObservableOrderedDictionary<KeyType: Hashable, ValueType>: OrderedDictionaryWrapper, ObservableCollection {
    public typealias _Self = ObservableOrderedDictionary<KeyType, ValueType>
    public typealias Base = OrderedDictionary<KeyType, ValueType>
    public typealias EventType = MulticastEvent<_Self, Items<Base.Iterator.Element>>
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
    
    public func replaceSubrange<C : Collection where C.Iterator.Element == Base.Iterator.Element>(_ subRange: Range<Base.Index>, with newElements: C) {
        oc_replaceRange(subRange) {
            innerCollection.replaceSubrange(subRange, with: newElements)
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
    
    public func index(after i: Base.Index) -> Base.Index {
        return innerCollection.index(after: i)
    }
    
    func updateValue(_ value: ValueType, forKey key: KeyType) -> ValueType? {
        return innerCollection.updateValue(value, forKey: key)
    }
    
    public func removeValueForKey(_ key: KeyType) {
        innerCollection.removeValueForKey(key)
    }
    
    public func indexOfKey(_ key: KeyType) -> Int? {
        return innerCollection.indexOfKey(key)
    }
    
    public func getValueForKey(_ key: KeyType) -> ValueType? {
        return innerCollection[key]
    }
    
    func handleInnerCollectionUpdate(_ index: Base.Index) {
        fireChangeItem(index)
    }
    
    func handleInnerCollectionMove(_ from: Base.Index?, to: Base.Index) {
        let element = innerCollection[to]
        if let from = from {
            fireRemoveItem(element, atIndex: from)
        }
        fireInsertItem(to)
    }
    
    func handleInnerCollectionRemove(_ index: Base.Index, element: Base.Element) {
        fireRemoveItem(element, atIndex: index)
    }
}
