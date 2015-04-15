//
//  OrderedDictionary.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 14.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

struct OrderedDictionary<KeyType : Hashable, ValueType> : DictionaryLiteralConvertible, CollectionType {
    var keys = [KeyType]()
    var data = Dictionary<KeyType, ValueType>()
    
    init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        for e in elements {
            self[e.0] = e.1
        }
    }
    
    var count: Int {
        return keys.count
    }
    
    /// The first element, or `nil` if the array is empty
    var first: (KeyType, ValueType)? {
        return data.isEmpty ? nil : self[0]
    }
    
    /// The last element, or `nil` if the array is empty
    var last: (KeyType, ValueType)? {
        return data.isEmpty ? nil : self[count - 1]
    }
    
    var startIndex: Int {
        return keys.startIndex
    }
    
    var endIndex: Int {
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
    
    subscript(position: Int) -> (KeyType, ValueType) {
        get {
            precondition(position < keys.count, "Index out-of-bounds")
            
            let key = keys[position]
            let value = data[key]!
            
            return (key, value)
        }
    }
    
    mutating func insert(value: ValueType, forKey key: KeyType, atIndex index: Int) -> ValueType?
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
    
    mutating func removeAtIndex(index: Int) -> (KeyType, ValueType)
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
    
    func generate() -> OrderedDictionaryGenerator<KeyType, ValueType> {
        return OrderedDictionaryGenerator(dictionary: self)
    }
}

struct OrderedDictionaryGenerator<KeyType: Hashable, ValueType> : GeneratorType {
    private let dictionary: OrderedDictionary<KeyType, ValueType>
    var index: Int
    
    init(dictionary: OrderedDictionary<KeyType, ValueType>) {
        self.dictionary = dictionary
        index = -1
    }
    
    mutating func next() -> (KeyType, ValueType)? {
        index++
        if (index < dictionary.count) {
            return dictionary[index]
        }
        return nil
    }
}