//
//  ObservableArray.swift
//  MVVMKit
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public struct ObservableArray<T>: ArrayLiteralConvertible, MutableCollectionType {
    public typealias ChangeCallback = (ObservableArray<T>, T, Int) -> ()
    
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
            onItemChanged?(self, newValue, index)
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
    
    public mutating func removeLast() -> T {
        return removeAtIndex(count - 1)
    }
    
    public mutating func insert(newElement: T, atIndex i: Int) {
        innerArray.insert(newElement, atIndex: i)
        onItemInserted?(self, newElement, i)
    }
    
    public mutating func removeAtIndex(index: Int) -> T {
        let item = innerArray.removeAtIndex(index)
        onItemRemoved?(self, item, index)
        return item
    }
    
    public func generate() -> IndexingGenerator<Array<T>> {
        return innerArray.generate()
    }
    
    public var onItemInserted: ChangeCallback?
    public var onItemRemoved: ChangeCallback?
    public var onItemChanged: ChangeCallback?
}