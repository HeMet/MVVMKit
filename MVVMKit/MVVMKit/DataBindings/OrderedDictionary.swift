//
//  OrderedDictionary.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 14.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public struct OrderedDictionary<KeyType : Hashable, ValueType> : DictionaryLiteralConvertible, MutableCollectionType {
    typealias DictionaryItem = (KeyType, ValueType)
    private(set) var keys = [KeyType]()
    var data = Dictionary<KeyType, ValueType>()
    
    public init(dictionaryLiteral elements: DictionaryItem...) {
        self.init(pairs: elements)
    }
    
    public init(pairs: [DictionaryItem]) {
        for e in pairs {
            self[e.0] = e.1
        }
    }
    
    public var count: Int {
        return keys.count
    }
    
    /// The first element, or `nil` if the array is empty
    public var first: DictionaryItem? {
        return data.isEmpty ? nil : self[0]
    }
    
    /// The last element, or `nil` if the array is empty
    public var last: DictionaryItem? {
        return data.isEmpty ? nil : self[count - 1]
    }
    
    public var startIndex: Int {
        return keys.startIndex
    }
    
    public var endIndex: Int {
        return keys.endIndex
    }
    
    subscript(key: KeyType) -> ValueType? {
        get {
            return data[key]
        }
        set {
            if newValue == nil {
                removeValueForKey(key)
            } else {
                if find(keys, key) == nil {
                    keys.append(key)
                }
                
                data[key] = newValue
            }
        }
    }
    
    public subscript(position: Int) -> DictionaryItem {
        get {
            precondition(position < keys.count, "Index out-of-bounds")
            
            let key = keys[position]
            let value = data[key]!
            
            return (key, value)
        }
        set {
            insert(newValue.1, forKey: newValue.0, atIndex: position)
        }
    }
    
    public mutating func insert(value: ValueType, forKey key: KeyType, atIndex index: Int) -> ValueType? {
        var adjustedIndex = index
        
        let existingValue = data[key]
        if existingValue != nil {
            let existingIndex = find(keys, key)!
            
            if existingIndex < index {
                adjustedIndex--
            }
            keys.removeAtIndex(existingIndex)
        }
        
        keys.insert(key, atIndex:adjustedIndex)
        data[key] = value
        
        return existingValue
    }
    
    public mutating func removeValueForKey(key: KeyType) {
        data.removeValueForKey(key)
    }
    
    public mutating func removeAtIndex(index: Int) -> DictionaryItem {
        precondition(index < keys.count, "Index out-of-bounds")
        
        let key = keys.removeAtIndex(index)
        let value = data.removeValueForKey(key)!
        
        return (key, value)
    }
    
    public mutating func extend<S: SequenceType where S.Generator.Element == DictionaryItem>(newElements: S) {
        let values = [DictionaryItem](newElements)
        let start = data.count
        let end = start + values.count
        
        for (k, v) in newElements {
            if data[k] != nil {
                fatalError("Key \(k) already exists. Extend is not designed for replacement.")
            }
            
            data[k] = v
            keys.append(k)
        }
    }
    
    public func indexOfKey(key: KeyType) -> Int? {
        return find(keys, key)
    }
    
    public func generate() -> IndexingGenerator<OrderedDictionary<KeyType, ValueType>> {
        return IndexingGenerator(self)
    }
}