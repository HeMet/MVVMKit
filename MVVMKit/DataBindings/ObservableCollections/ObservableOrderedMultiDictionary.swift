//
//  ObservableOrderedMultiDictionary.swift
//  MVVMKit
//
//  Created by Евгений Губин on 14.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

/*
public final class ObservableOrderedMultiDictionary<KeyType : Hashable, SubValueType>: BaseObservableOrderedDictionary<KeyType, ObservableArray<SubValueType>>, ObservableCollection, MutableCollectionType {
    public typealias ValueType = ObservableArray<SubValueType>
    public typealias InnerDictionary = OrderedDictionary<KeyType, ValueType>
    
    public typealias ItemType = (KeyType, ValueType)
    public typealias RangeChangedEvent = MulticastEvent<ObservableOrderedMultiDictionary, ([ItemType], Range<Int>)>
    public typealias UpdatePhaseEvent = MulticastEvent<ObservableOrderedMultiDictionary, UpdatePhase>
    
    public typealias SubItemsChangedEventArgs = (SubValueType, Int, Int)
    public typealias SubItemsChangedEvent = MulticastEvent<ObservableOrderedMultiDictionary, [SubItemsChangedEventArgs]>
    
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
    
    func convertArrayEventToSelfEvent(sender: ValueType, _ args: ([SubValueType], Range<Int>)) -> [SubItemsChangedEventArgs] {
        let valueIdx = indexOfValue(sender)!
        let (items, idxs) = args
        return convertToIndexPath(valueIdx, subItems: items, idxs: idxs)
    }
    
    func convertToIndexPath(sectionIdx: Int, subItems: [SubValueType], idxs: Range<Int>) -> [SubItemsChangedEventArgs] {
        var result: [SubItemsChangedEventArgs] = []
        var i = 0
        for idx in idxs {
            let item: SubItemsChangedEventArgs = (subItems[i], sectionIdx, idx)
            result.append(item)
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
*/