//
//  ObservableOrderedDictionary.swift
//  MVVMKit
//
//  Created by Евгений Губин on 19.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public class BaseObservableOrderedDictionary<KeyType : Hashable, ValueType> : DictionaryLiteralConvertible, MutableCollectionType {
    typealias ItemType = (KeyType, ValueType)
    
    var innerDictionary = OrderedDictionary<KeyType, ValueType>()
    
    public required convenience init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        self.init(data: elements)
    }
    
    public convenience required init(data: [ItemType]) {
        self.init()
        innerDictionary = OrderedDictionary(pairs: data)
    }
    
    public var keys: [KeyType] {
        return innerDictionary.keys
    }
    
    public var count: Int {
        return innerDictionary.count
    }
    
    /// The first element, or `nil` if the array is empty
    public var first: ItemType? {
        return innerDictionary.first
    }
    
    /// The last element, or `nil` if the array is empty
    public var last: ItemType? {
        return innerDictionary.last
    }
    
    public var startIndex: Int {
        return innerDictionary.startIndex
    }
    
    public var endIndex: Int {
        return innerDictionary.endIndex
    }
    
    subscript(key: KeyType) -> ValueType? {
        get {
            return innerDictionary[key]
        }
        set {
            if let newValue = newValue {
                let keyExists = contains(innerDictionary.keys, key)
                
                innerDictionary[key] = newValue
                
                let index = indexOfKey(key)!
                let range = newRangeOf(index)
                
                let event = keyExists ? fireChange : fireInsert
                event([(key, newValue)], range)
            } else {
                removeValueForKey(key)
            }
        }
    }
    
    public subscript(position: Int) -> ItemType {
        get {
            return innerDictionary[position]
        }
        set {
            let oldIndex = indexOfKey(newValue.0)
            let oldValue = innerDictionary[newValue.0]
            
            innerDictionary[position] = newValue
            
            if let oldValue = oldValue, let oldIndex = oldIndex {
                if (oldIndex == position) {
                    fireChange([newValue], newRangeOf(position))
                } else {
                    fireBatchUpdate(.Begin)
                    fireRemove([(newValue.0, oldValue)], newRangeOf(oldIndex))
                    fireInsert([newValue], newRangeOf(position))
                    fireBatchUpdate(.End)
                }
            } else {
                fireInsert([newValue], newRangeOf(position))
            }
        }
    }
    
    public func removeValueForKey(key: KeyType) {
        if let keyIndex = find(innerDictionary.keys, key) {
            removeAtIndex(keyIndex)
        }
    }
    
    public func removeAtIndex(index: Int) -> ItemType {
        let di = innerDictionary.removeAtIndex(index)
        fireRemove([di], newRangeOf(index))
        return di
    }
    
    public func extend<S: SequenceType where S.Generator.Element == ItemType>(newElements: S) {
        let values = [ItemType](newElements)
        let start = innerDictionary.count
        let end = start + values.count
        
        innerDictionary.extend(newElements)
        
        fireInsert(values, Range(start: start, end: end))
    }
    
    public func indexOfKey(key: KeyType) -> Int? {
        return innerDictionary.indexOfKey(key)
    }
    
    public func generate() -> IndexingGenerator<BaseObservableOrderedDictionary<KeyType, ValueType>> {
        return IndexingGenerator(self)
    }
    
    func fireInsert(items: [ItemType], _ idxs: Range<Int>) {
        fatalError("Abstract method.")
    }
    
    func fireRemove(items: [ItemType], _ idxs: Range<Int>) {
        fatalError("Abstract method.")
    }
    
    func fireChange(items: [ItemType], _ idxs: Range<Int>) {
        fatalError("Abstract method.")
    }
    
    func fireBatchUpdate(phase: UpdatePhase) {
        fatalError("Abstract method.")
    }
}

public final class ObservableOrderedDictionary<KeyType: Hashable, ValueType>: BaseObservableOrderedDictionary<KeyType, ValueType>, ObservableCollection {
    typealias ItemType = (KeyType, ValueType)
    public typealias RangeChangedEvent = MulticastEvent<ObservableOrderedDictionary, ([ItemType], Range<Int>)>
    public typealias UpdatePhaseEvent = MulticastEvent<ObservableOrderedDictionary, UpdatePhase>
    
    public var onDidInsertRange: RangeChangedEvent!
    public var onDidRemoveRange: RangeChangedEvent!
    public var onDidChangeRange: RangeChangedEvent!
    
    public var onBatchUpdate: UpdatePhaseEvent!

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

// Keep it here, otherwise complier will crash.

public final class ObservableOrderedMultiDictionary<KeyType : Hashable, SubValueType>: BaseObservableOrderedDictionary<KeyType, ObservableArray<SubValueType>>, ObservableCollection {
    typealias ValueType = ObservableArray<SubValueType>
    typealias InnerDictionary = OrderedDictionary<KeyType, ValueType>
    
    typealias ItemType = (KeyType, ValueType)
    public typealias RangeChangedEvent = MulticastEvent<ObservableOrderedMultiDictionary, ([ItemType], Range<Int>)>
    public typealias UpdatePhaseEvent = MulticastEvent<ObservableOrderedMultiDictionary, UpdatePhase>
    
    typealias SubItemsChangedEvent = MulticastEvent<ObservableOrderedMultiDictionary, [(SubValueType, Int, Int)]>
    
    let observerTag = "ObservableOrderedMultiDictionary_observer_tag"
    
    var updateCounter = 0
    
    public var onDidInsertRange: RangeChangedEvent!
    public var onDidRemoveRange: RangeChangedEvent!
    public var onDidChangeRange: RangeChangedEvent!

    public var onBatchUpdate: UpdatePhaseEvent!
    
    public var onDidInsertSubItems: SubItemsChangedEvent!
    public var onDidRemoveSubItems: SubItemsChangedEvent!
    public var onDidChangeSubItems: SubItemsChangedEvent!
    
    public required convenience init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        self.init(data: elements)
    }
    
    public convenience required init(data: [ItemType]) {
        self.init()
        innerDictionary = InnerDictionary(pairs: data)
    }
    
    public override init() {
        super.init()
        onDidInsertRange = RangeChangedEvent(context: self)
        onDidRemoveRange = RangeChangedEvent(context: self)
        onDidChangeRange = RangeChangedEvent(context: self)
        onBatchUpdate = UpdatePhaseEvent(context: self)
        
        onDidInsertSubItems = SubItemsChangedEvent(context: self)
        onDidRemoveSubItems = SubItemsChangedEvent(context: self)
        onDidChangeSubItems = SubItemsChangedEvent(context: self)
    }
    
    public override subscript(key: KeyType) -> ValueType? {
        get {
            return super[key]
        }
        set {
            if let oldValue = innerDictionary[key] {
                stopListeningFor(oldValue)
            }
            
            super[key] = newValue
            
            if let newValue = newValue {
                beginListeningFor(newValue)
            }
        }
    }
    
    public override subscript(position: Int) -> ItemType {
        get {
            return super[position]
        }
        set {
            let oldValue = innerDictionary[position]
            stopListeningFor(oldValue.1)
            
            super[position] = newValue
            
            beginListeningFor(newValue.1)
        }
    }
    
    func beginListeningFor(item: ValueType) {
        item.onDidInsertRange.register(observerTag) { sender, args in
            let eventArgs = self.convertArrayEventToSelfEvent(sender, args)
            self.onDidInsertSubItems.fire(eventArgs)
        }
        item.onDidRemoveRange.register(observerTag) { sender, args in
            let eventArgs = self.convertArrayEventToSelfEvent(sender, args)
            self.onDidRemoveSubItems.fire(eventArgs)
        }
        item.onDidChangeRange.register(observerTag) { sender, args in
            let eventArgs = self.convertArrayEventToSelfEvent(sender, args)
            self.onDidChangeSubItems.fire(eventArgs)
        }
        
        item.onBatchUpdate.register(observerTag) { sender, args in
            switch args {
            case .Begin:
                self.updateCounter++
                if (self.updateCounter == 1) {
                    self.onBatchUpdate.fire(.Begin)
                }
            case .End:
                precondition(self.updateCounter >= 0, "Batch update calls are unbalanced")
                self.updateCounter--
                if (self.updateCounter == 0) {
                    self.onBatchUpdate.fire(.End)
                }
            }
        }
    }
    
    func indexOfValue(item: ValueType) -> Int? {
        for (k, v) in self {
            if v === item {
                return indexOfKey(k)
            }
        }
        return nil
    }
    
    func convertArrayEventToSelfEvent(sender: ValueType, _ args: ([SubValueType], Range<Int>)) -> [(SubValueType, Int, Int)] {
        let valueIdx = indexOfValue(sender)!
        let (items, idxs) = args
        return convertToIndexPath(valueIdx, subItems: items, idxs: idxs)
    }
    
    func convertToIndexPath(sectionIdx: Int, subItems: [SubValueType], idxs: Range<Int>) -> [(SubValueType, Int, Int)] {
        var result: [(SubValueType, Int, Int)] = []
        var i = 0
        for idx in idxs {
            result.append(subItems[i], sectionIdx, idx)
            i++
        }
        return result
    }
    
    func stopListeningFor(item: ValueType) {
        item.onDidInsertRange.unregister(observerTag)
        item.onDidRemoveRange.unregister(observerTag)
        item.onDidChangeRange.unregister(observerTag)
        item.onBatchUpdate.unregister(observerTag)
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