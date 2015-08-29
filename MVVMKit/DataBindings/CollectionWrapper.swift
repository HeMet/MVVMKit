//
//  CollectionWrapper.swift
//  MVVMKit
//
//  Created by Евгений Губин on 16.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

public protocol CollectionWrapper: class, CollectionType {
    typealias Base: CollectionType
    
    var innerCollection: Base { get }
}

public protocol MutableCollectionWrapper: CollectionWrapper, MutableCollectionType {
    typealias Base: MutableCollectionType
    
    var innerCollection: Base { get set }
}

public protocol RangeReplaceableCollectionWrapper: CollectionWrapper, RangeReplaceableCollectionType {
    typealias Base: RangeReplaceableCollectionType
    
    var innerCollection: Base { get set }
}

public protocol MutableSliceableWrapper: MutableCollectionWrapper, MutableSliceable {
    typealias Base: MutableSliceable
}

extension CollectionWrapper {
    public var startIndex: Base.Index {
        return innerCollection.startIndex
    }
    
    public var endIndex: Base.Index {
        return innerCollection.endIndex
    }
    
    subscript(position: Base.Index) -> Base.Generator.Element {
        get {
            return innerCollection[position]
        }
    }
}

extension MutableCollectionWrapper {
    subscript(position: Base.Index) -> Base.Generator.Element {
        get {
            return innerCollection[position]
        }
        set {
            innerCollection[position] = newValue
        }
    }
}

extension RangeReplaceableCollectionWrapper {
    func replaceRange<C : CollectionType where C.Generator.Element == Base.Generator.Element>(subRange: Range<Base.Index>, with newElements: C) {
        innerCollection.replaceRange(subRange, with: newElements)
    }
}

extension MutableSliceableWrapper {
    public subscript(range: Range<Base.Index>) -> Base.SubSequence {
        get {
            return innerCollection[range]
        }
        set {
            innerCollection[range] = newValue
        }
    }
}

public protocol ArrayWrapper: RangeReplaceableCollectionWrapper, MutableSliceableWrapper, ArrayLiteralConvertible {
    typealias Base: MutableSliceable, RangeReplaceableCollectionType, ArrayLiteralConvertible
}

public protocol OrderedDictionaryWrapper: RangeReplaceableCollectionWrapper, MutableSliceableWrapper, DictionaryLiteralConvertible {
    typealias Base: MutableSliceable, RangeReplaceableCollectionType, DictionaryLiteralConvertible
}

extension ArrayWrapper where Base == [Element] {
    public init(arrayLiteral elements: Base.Element...) {
        self.init()
        innerCollection = Array(elements)
    }
}

// Keep them here to avoid linker error

class BaseArrayWrapper<T>: ArrayWrapper {
    typealias Base = Array<T>
    
    var innerCollection: Base = []
    
    required init() {
        
    }
    
    required init(arrayLiteral elements: T...) {
        innerCollection = Array(elements)
    }
}

class BaseOrderedDictionaryWrapper<KeyType: Hashable, ValueType>: OrderedDictionaryWrapper {
    typealias Base = OrderedDictionary<KeyType, ValueType>
    
    var innerCollection: Base = [:]
    
    required init() {
        
    }
    
    required init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        innerCollection = OrderedDictionary(pairs: elements)
    }
}