//
//  ObservableOrderedDictionary.swift
//  MVVMKit
//
//  Created by Евгений Губин on 19.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public class ObservableOrderedDictionary<KeyType : Hashable, ValueType> : DictionaryLiteralConvertible, MutableCollectionType, ObservableCollection {
    typealias ItemType = (KeyType, ValueType)

    public typealias RangeChangedEvent = MulticastEvent<ObservableOrderedDictionary<KeyType, ValueType>, ([ItemType], Range<Int>)>
    public typealias UpdatePhaseEvent = MulticastEvent<ObservableOrderedDictionary<KeyType, ValueType>, UpdatePhase>
    
    var innerDictionary = OrderedDictionary<KeyType, ValueType>()
    
    public var onDidInsertRange: RangeChangedEvent!
    public var onDidRemoveRange: RangeChangedEvent!
    public var onDidChangeRange: RangeChangedEvent!
    
    public var onBatchUpdate: UpdatePhaseEvent!
    
    public required convenience init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        self.init(pairs: elements)
    }
    
    public convenience init(pairs: [ItemType]) {
        self.init()
        innerDictionary = OrderedDictionary(pairs: pairs)
    }
    
    init() {
        onDidInsertRange = RangeChangedEvent(context: self)
        onDidRemoveRange = RangeChangedEvent(context: self)
        onDidChangeRange = RangeChangedEvent(context: self)
        onBatchUpdate = UpdatePhaseEvent(context: self)
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
                
                let index = find(innerDictionary.keys, key)!
                let range = newRangeOf(index)
                
                let event = keyExists ? onDidChangeRange : onDidInsertRange
                event.fire([(key, newValue)], range)
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
            let oldIndex = find(innerDictionary.keys, newValue.0)
            let oldValue = innerDictionary[newValue.0]
            
            innerDictionary[position] = newValue
            
            if let oldValue = oldValue, let oldIndex = oldIndex {
                if (oldIndex == position) {
                    onDidChangeRange.fire([newValue], newRangeOf(position))
                } else {
                    batchUpdate(self) {
                        self.onDidRemoveRange.fire([(newValue.0, oldValue)], newRangeOf(oldIndex))
                        self.onDidInsertRange.fire([newValue], newRangeOf(position))
                    }
                }
            } else {
                onDidInsertRange.fire([newValue], newRangeOf(position))
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
        onDidRemoveRange.fire([di], newRangeOf(index))
        return di
    }
    
    public func extend<S: SequenceType where S.Generator.Element == ItemType>(newElements: S) {
        let values = [ItemType](newElements)
        let start = innerDictionary.count
        let end = start + values.count
        
        innerDictionary.extend(newElements)
        
        onDidInsertRange.fire(values, Range(start: start, end: end))
    }
    
    public func generate() -> IndexingGenerator<ObservableOrderedDictionary<KeyType, ValueType>> {
        return IndexingGenerator(self)
    }
}