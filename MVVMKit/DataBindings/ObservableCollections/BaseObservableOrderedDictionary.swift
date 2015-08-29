//
//  BaseObservableOrderedDictionary.swift
//  MVVMKit
//
//  Created by Евгений Губин on 14.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

public class BaseObservableOrderedDictionary<KeyType : Hashable, ValueType> : DictionaryLiteralConvertible {
    public typealias ItemType = (KeyType, ValueType)
    
    var innerDictionary = OrderedDictionary<KeyType, ValueType>()
    
    public required convenience init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        self.init()
        innerDictionary = OrderedDictionary(pairs: elements)
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
                let keyExists = innerDictionary.keys.contains(key)
                
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
    
    public func valueForKey(key: KeyType) -> ValueType? {
        return self[key]
    }
    
    public func itemAtIndex(index: Int) -> ItemType {
        return self[index]
    }
    
    public func removeValueForKey(key: KeyType) {
        if let keyIndex = innerDictionary.keys.indexOf(key) {
            removeAtIndex(keyIndex)
        }
    }
    
    public func removeAtIndex(index: Int) -> ItemType {
        let di = innerDictionary.removeAtIndex(index)
        fireRemove([di], newRangeOf(index))
        return di
    }
    
    public func appendContentsOf<S: SequenceType where S.Generator.Element == ItemType>(newElements: S) {
        let values = [ItemType](newElements)
        let start = innerDictionary.count
        let end = start + values.count
        
        innerDictionary.appendContentsOf(newElements)
        
        fireInsert(values, Range(start: start, end: end))
    }
    
    public func indexOfKey(key: KeyType) -> Int? {
        return innerDictionary.indexOfKey(key)
    }
    
//    public func generate() -> IndexingGenerator<BaseObservableOrderedDictionary<KeyType, ValueType>> {
//        return IndexingGenerator(self)
//    }
    
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
