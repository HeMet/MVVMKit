//
//  ObservableArray.swift
//  MVVMKit
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public struct ObservableArray<T>: ArrayLiteralConvertible, MutableCollectionType {
    public typealias RangeChangedCallback = (ObservableArray<T>, [T], Range<Int>) -> ()
    
    var innerArray: [T] = []
    
    public init(arrayLiteral array: T...) {
        self.init(array: array)
    }
    
    public init(array: [T]) {
        innerArray = array
    }
    
    public init() {
        
    }
    
    public var count: Int {
        return innerArray.count
    }
    
    public var isEmpty: Bool {
        return innerArray.isEmpty
    }
    
    public subscript (index: Int) -> T {
        get {
            return innerArray[index]
        }
        set {
            innerArray[index] = newValue
            onItemsChanged?(self, [newValue], newRangeOf(index))
        }
    }
    
    public var startIndex: Int {
        return innerArray.startIndex
    }
    
    public var endIndex: Int {
        return innerArray.endIndex
    }

    
    public mutating func append(newElement: T) {
        insert(newElement, atIndex: count)
    }
    
    public mutating func extend<S: SequenceType where S.Generator.Element == T>(newElements: S) {
        let values = [T](newElements)
        let start = innerArray.count
        let end = start + values.count - 1
        
        innerArray.extend(values)
        
        onItemsInserted?(self, values, Range(start: start, end: end))
    }
    
    public mutating func removeLast() -> T {
        return removeAtIndex(count - 1)
    }
    
    public mutating func insert(newElement: T, atIndex i: Int) {
        innerArray.insert(newElement, atIndex: i)
        onItemsInserted?(self, [newElement], newRangeOf(i))
    }
    
    public mutating func removeAtIndex(index: Int) -> T {
        let item = innerArray.removeAtIndex(index)
        onItemsRemoved?(self, [item], newRangeOf(index))
        return item
    }
    
    public func generate() -> IndexingGenerator<Array<T>> {
        return innerArray.generate()
    }
    
    
    func newRangeOf(value: Int) -> Range<Int> {
        return Range(start: value, end: value)
    }
    
    public var onItemsInserted: RangeChangedCallback?
    public var onItemsRemoved: RangeChangedCallback?
    public var onItemsChanged: RangeChangedCallback?
}