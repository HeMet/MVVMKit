//
//  OrderedDictionary.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 14.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public struct OrderedDictionary<KeyType : Hashable, ValueType> : DictionaryLiteralConvertible, CollectionType {
    typealias DictionaryItem = (KeyType, ValueType)
    var keys = [KeyType]()
    var data = Dictionary<KeyType, ValueType>()
    
    public init(dictionaryLiteral elements: DictionaryItem...) {
        for e in elements {
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
            if let index = find(keys, key) {
            } else {
                keys.append(key)
            }
            
            data[key] = newValue
        }
    }
    
    public subscript(position: Int) -> DictionaryItem {
        get {
            precondition(position < keys.count, "Index out-of-bounds")
            
            let key = keys[position]
            let value = data[key]!
            
            return (key, value)
        }
    }
    
    public mutating func insert(value: ValueType, forKey key: KeyType, atIndex index: Int) -> ValueType?
    {
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
    
    public mutating func removeAtIndex(index: Int) -> DictionaryItem
    {
        precondition(index < keys.count, "Index out-of-bounds")
        
        let key = keys.removeAtIndex(index)
        let value = data.removeValueForKey(key)!
        
        return (key, value)
    }
    
    mutating func addDictionaryUnordered(dictionary: Dictionary<KeyType, ValueType>) {
        for e in dictionary {
            self[e.0] = e.1
        }
    }
    
    public mutating func addElements(elements: [DictionaryItem]) {
        for e in elements {
            self[e.0] = e.1
        }
    }
    
    public func generate() -> OrderedDictionaryGenerator<KeyType, ValueType> {
        return OrderedDictionaryGenerator(dictionary: self)
    }
}

public struct OrderedDictionaryGenerator<KeyType: Hashable, ValueType> : GeneratorType {
    private let dictionary: OrderedDictionary<KeyType, ValueType>
    var index: Int
    
    init(dictionary: OrderedDictionary<KeyType, ValueType>) {
        self.dictionary = dictionary
        index = -1
    }
    
    mutating public func next() -> (KeyType, ValueType)? {
        index++
        if (index < dictionary.count) {
            return dictionary[index]
        }
        return nil
    }
}