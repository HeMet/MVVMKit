//
//  CollectionWrapper.swift
//  MVVMKit
//
//  Created by Евгений Губин on 16.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

public protocol CollectionWrapper: class, Collection {
    associatedtype Base: Collection
    
    var innerCollection: Base { get }
}

public protocol MutableCollectionWrapper: CollectionWrapper, MutableCollection {
    associatedtype Base: MutableCollection
    
    var innerCollection: Base { get set }
}

public protocol RangeReplaceableCollectionWrapper: CollectionWrapper, RangeReplaceableCollection {
    associatedtype Base: RangeReplaceableCollection
    
    var innerCollection: Base { get set }
}

//public protocol MutableSliceableWrapper: MutableCollectionWrapper, MutableCollection {
//    associatedtype Base: MutableCollection
//}

extension CollectionWrapper {
    public var startIndex: Base.Index {
        return innerCollection.startIndex
    }
    
    public var endIndex: Base.Index {
        return innerCollection.endIndex
    }
    
    subscript(position: Base.Index) -> Base.Iterator.Element {
        get {
            return innerCollection[position]
        }
    }
}

extension MutableCollectionWrapper {
    subscript(position: Base.Index) -> Base.Iterator.Element {
        get {
            return innerCollection[position]
        }
        set {
            innerCollection[position] = newValue
        }
    }
}

extension RangeReplaceableCollectionWrapper {
    public func replaceSubrange<C : Collection where C.Iterator.Element == Base.Iterator.Element>(_ subRange: Range<Base.Index>, with newElements: C) {
        innerCollection.replaceSubrange(subRange, with: newElements)
    }
}

extension MutableCollectionWrapper {
    public subscript(range: Range<Base.Index>) -> Base.SubSequence {
        get {
            return innerCollection[range]
        }
        set {
            innerCollection[range] = newValue
        }
    }
}

public protocol ArrayWrapper: RangeReplaceableCollectionWrapper, MutableCollectionWrapper, ArrayLiteralConvertible {
    associatedtype Base: MutableCollection, RangeReplaceableCollection, ArrayLiteralConvertible
}

public protocol OrderedDictionaryWrapper: RangeReplaceableCollectionWrapper, MutableCollectionWrapper, DictionaryLiteralConvertible {
    associatedtype Base: MutableCollection, RangeReplaceableCollection, DictionaryLiteralConvertible
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
    
    func index(after i: Base.Index) -> Base.Index {
        return innerCollection.index(after: i)
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
    
    func index(after i: Base.Index) -> Base.Index {
        return innerCollection.index(after: i)
    }
}
