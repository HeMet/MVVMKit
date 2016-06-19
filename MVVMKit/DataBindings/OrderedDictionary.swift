//
//  OrderedDictionary.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 14.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public struct OrderedDictionary<KeyType : Hashable, ValueType> : DictionaryLiteralConvertible, RangeReplaceableCollection, MutableCollection {
    public typealias Base = [KeyType: ValueType]
    public typealias Iterator = IndexingIterator<OrderedDictionary>
    public typealias Element = (KeyType, ValueType)
    public typealias Index = Int
    public typealias SubSequence = OrderedDictionary
    
    private(set) var keys = [KeyType]()
    var data = Base()
    
    // DictionaryLiteralConvertible
    
    public init(dictionaryLiteral elements: Element...) {
        self.init(pairs: elements)
    }
    
    public init(pairs: [Element]) {
        for e in pairs {
            self[e.0] = e.1
        }
    }
    
    // RangeReplaceableCollectionType
    
    public init() {
        
    }
    
    // Indexable
    
    public var startIndex: Int {
        return keys.startIndex
    }
    
    public var endIndex: Int {
        return keys.endIndex
    }
    
    public func index(after i: Int) -> Int {
        return i + 1;
    }
    
    // [Mutable]CollectionType
    
    public subscript(position: Index) -> Element {
        get {
            precondition(position < keys.count, "Index out-of-bounds")
            
            let key = keys[position]
            let value = data[key]!
            
            return (key, value)
        }
        set {
            if keys.index(of: newValue.0) == position {
                updateValue(newValue.1, forKey: newValue.0)
            } else {
                insert(newValue.1, forKey: newValue.0, atIndex: position)
            }
        }
    }
    
    // MutableSliceable & CollectionType
    
    public subscript(range: Range<Index>) -> SubSequence {
        get {
            var result = OrderedDictionary()
            result.keys = Array(keys[range])
            result.data = Base(minimumCapacity: range.count)
            for k in result.keys {
                result.data[k] = self[k]
            }

            return result
        }
        set {
            replaceSubrange(range, with: newValue)
        }
    }
    
    // RangeReplaceableCollectionType
    
    public mutating func replaceSubrange<C: Collection where C.Iterator.Element == Iterator.Element>(_ subRange: Range<Index>, with newElements: C) {
        for i in CountableRange(subRange) {
            data[keys[i]] = nil
        }
        
        let keysToInsert = newElements.map { $0.0 }
        keys.replaceSubrange(subRange, with: keysToInsert)
        
        for (k, v) in newElements {
            data[k] = v
        }
    }
    
    // SequenceType
    
    // Compares OrderedDictionary to Dictionary ignoring keys order.
    func elementsEqual(_ other: Dictionary<KeyType, ValueType>, isEquivalent: @noescape (Element, Element) -> Bool) -> Bool {
        guard count == other.count else { return false }
        
        for e in other {
            guard let selfE = self[e.0] where isEquivalent(e, (e.0, selfE)) else {
                return false
            }
        }
        return true
    }
    
    // Dictionary
    
    // If key exists then change it's value.
    // If key is not exist then append it to the dictionary.
    // If new value is null then remove key-value pair from the dictionary.
    subscript(key: KeyType) -> ValueType? {
        get {
            return data[key]
        }
        set {
            if let newValue = newValue {
                if let _ = keys.index(of: key) {
                    updateValue(newValue, forKey: key)
                } else {
                    insert(newValue, forKey: key, atIndex: count)
                }
            } else {
                removeValueForKey(key)
            }
        }
    }
    
    // Next three methods do all real work with except for replaceRange
    
    @discardableResult
    public mutating func insert(_ value: ValueType, forKey key: KeyType, atIndex index: Index) -> ValueType? {
        let existingValue = data[key]
        let existingIndex = keys.index(of: key)
        
        if existingValue != nil {
            keys.remove(at: existingIndex!)
        }
    
        keys.insert(key, at:index)
        data[key] = value
        
        onMove?(existingIndex, index)
        
        return existingValue
    }
    
    @discardableResult
    mutating func updateValue(_ value: ValueType, forKey key: KeyType) -> ValueType? {
        let existingValue = data[key]
        data[key] = value
        onUpdate?(keys.index(of: key)!)
        return existingValue
    }
    
    public mutating func removeValueForKey(_ key: KeyType) {
        let index = keys.index(of: key)!
        keys.remove(at: index)
        let value = data[key]!
        data[key] = nil
        onRemove?(index, (key, value))
    }
    
    public func indexOfKey(_ key: KeyType) -> Int? {
        return keys.index(of: key)
    }
    
    public func getValueForKey(_ key: KeyType) -> ValueType? {
        return self[key]
    }
    
    var onUpdate: ((Index) -> ())?
    var onRemove: ((Index, Element) -> ())?
    var onMove: ((Index?, Index) -> ())?
}

extension OrderedDictionary: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result = "[\n"
        for i in self.startIndex..<self.endIndex {
            let elem = self[i]
            result += "\(i) - \(elem.0): \(elem.1)\n"
        }
        return result + "]\n"
    }
}
