//
//  ObservableArray.swift
//  MVVMKit
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public enum UpdatePhase {
    case Begin, End
}

public final class ObservableArray<T>: ArrayLiteralConvertible, MutableCollectionType, ObservableCollection {
    typealias ItemType = T
    public typealias RangeChangedEvent = MulticastEvent<ObservableArray, ([T], Range<Int>)>
    public typealias UpdatePhaseEvent = MulticastEvent<ObservableArray, UpdatePhase>
    
    var innerArray: [T] = []
    
    public var onDidInsertRange: RangeChangedEvent!
    public var onDidRemoveRange: RangeChangedEvent!
    public var onDidChangeRange: RangeChangedEvent!
    
    public var onBatchUpdate: UpdatePhaseEvent!
    
    public required convenience init(arrayLiteral array: T...) {
        self.init(data: array)
    }
    
    public convenience required init(data: [T]) {
        self.init()
        innerArray = data
    }
    
    public init() {
        onDidInsertRange = RangeChangedEvent(context: self)
        onDidRemoveRange = RangeChangedEvent(context: self)
        onDidChangeRange = RangeChangedEvent(context: self)
        onBatchUpdate = UpdatePhaseEvent(context: self)
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
            onDidChangeRange.fire([newValue], newRangeOf(index))
        }
    }
    
    public var startIndex: Int {
        return innerArray.startIndex
    }
    
    public var endIndex: Int {
        return innerArray.endIndex
    }

    
    public func append(newElement: T) {
        insert(newElement, atIndex: count)
    }
    
    public func extend<S: SequenceType where S.Generator.Element == T>(newElements: S) {
        let values = [T](newElements)
        let start = innerArray.count
        let end = start + values.count
        
        innerArray.extend(values)
        onDidInsertRange.fire(values, Range(start: start, end: end))
    }
    
    public func removeLast() -> T {
        return removeAtIndex(count - 1)
    }
    
    public func insert(newElement: T, atIndex i: Int) {
        innerArray.insert(newElement, atIndex: i)
        onDidInsertRange.fire([newElement], newRangeOf(i))
    }
    
    public func removeAtIndex(index: Int) -> T {
        let item = innerArray.removeAtIndex(index)
        onDidRemoveRange.fire([item], newRangeOf(index))
        return item
    }
    
    public func removeAll(keepCapacity: Bool) {
        let start = 0
        let end = innerArray.count
        
        let removed = innerArray
        
        innerArray.removeAll(keepCapacity: keepCapacity)
        onDidRemoveRange.fire(removed, Range(start: start, end: end))
    }
    
    public func replaceAll<S: SequenceType where S.Generator.Element == T>(newElements: S) {
        onBatchUpdate.fire(.Begin)
        removeAll(true)
        extend(newElements)
        onBatchUpdate.fire(.End)
    }
    
    public func generate() -> IndexingGenerator<Array<T>> {
        return innerArray.generate()
    }
    
    
    func newRangeOf(value: Int) -> Range<Int> {
        return Range(start: value, end: value + 1)
    }
}