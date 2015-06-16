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

public class ObservableArray<T>: ArrayLiteralConvertible, MutableCollectionType {
    public typealias RangeChangedCallback = (ObservableArray<T>, [T], Range<Int>) -> ()
    public typealias UpdatePhaseCallback = (ObservableArray<T>, UpdatePhase) -> ()
    
    var innerArray: [T] = []
    
    // there is no good way in swift to compare two closures (it's intentional)
    var insertObservers: [String:RangeChangedCallback] = [String:RangeChangedCallback]()
    var removeObservers: [String:RangeChangedCallback] = [String:RangeChangedCallback]()
    var changeObservers: [String:RangeChangedCallback] = [String:RangeChangedCallback]()
    
    var updatePhaseObservers: [String: UpdatePhaseCallback] = [String: UpdatePhaseCallback]()
    
    public required convenience init(arrayLiteral array: T...) {
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
            broadcast([newValue], indexes: newRangeOf(index), observers: changeObservers)
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
        broadcast(values, indexes: Range(start: start, end: end), observers: insertObservers)
    }
    
    public func removeLast() -> T {
        return removeAtIndex(count - 1)
    }
    
    public func insert(newElement: T, atIndex i: Int) {
        innerArray.insert(newElement, atIndex: i)
        broadcast([newElement], indexes: newRangeOf(i), observers: insertObservers)
    }
    
    public func removeAtIndex(index: Int) -> T {
        let item = innerArray.removeAtIndex(index)
        broadcast([item], indexes: newRangeOf(index), observers: removeObservers)
        return item
    }
    
    public func removeAll(keepCapacity: Bool) {
        let start = 0
        let end = innerArray.count
        
        let removed = innerArray
        
        innerArray.removeAll(keepCapacity: keepCapacity)
        broadcast(removed, indexes: Range(start: start, end: end), observers: removeObservers)
    }
    
    public func replaceAll<S: SequenceType where S.Generator.Element == T>(newElements: S) {
        broadcast(.Begin, observers: updatePhaseObservers)
        removeAll(true)
        extend(newElements)
        broadcast(.End, observers: updatePhaseObservers)
    }
    
    public func generate() -> IndexingGenerator<Array<T>> {
        return innerArray.generate()
    }
    
    
    func newRangeOf(value: Int) -> Range<Int> {
        return Range(start: value, end: value + 1)
    }
    
    public func registerInsertObserver(tag: String, observer: RangeChangedCallback) {
        insertObservers[tag] = observer
    }
    
    public func registerRemoveObserver(tag: String, observer: RangeChangedCallback) {
        removeObservers[tag] = observer
    }
    
    public func registerChangeObserver(tag: String, observer: RangeChangedCallback) {
        insertObservers[tag] = observer
    }
    
    public func registerUpdatePhaseObserver(tag: String, observer: UpdatePhaseCallback) {
        updatePhaseObservers[tag] = observer
    }
    
    public func unregisterInsertObserver(tag: String) {
        insertObservers.removeValueForKey(tag)
    }
    
    public func unregisterRemoveObserver(tag: String) {
        removeObservers.removeValueForKey(tag)
    }

    public func unregisterChangeObserver(tag: String) {
        changeObservers.removeValueForKey(tag)
    }

    public func unregisterUpdatePhaseObserver(tag: String) {
        updatePhaseObservers.removeValueForKey(tag)
    }
    
    func broadcast(items: [T], indexes: Range<Int>, observers: [String: RangeChangedCallback]) {
        for (_, o) in observers {
            o(self, items, indexes)
        }
    }
    
    func broadcast(phase: UpdatePhase, observers: [String: UpdatePhaseCallback]) {
        for (_, o) in observers {
            o(self, phase)
        }
    }
}