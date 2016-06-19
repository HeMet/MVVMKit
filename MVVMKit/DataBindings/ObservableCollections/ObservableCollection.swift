//
//  ObservableCollection.swift
//  MVVMKit
//
//  Created by Евгений Губин on 20.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public enum UpdatePhase {
    case begin, end
}

public protocol ObservableCollection: class, Collection {
    associatedtype EventType = MulticastEvent<Self, Items<Generator.Element>>
    associatedtype BatchUpdateEventType = MulticastEvent<Self, UpdatePhase>
    
    // Using of typealias causes compiler crash in extension
    
    // Slice points to original collection, so it doesn't work for removing
    // Workaround: make copy of collection and pass that copy to slice. What about memory consumption?
    var onDidInsertItems: MulticastEvent<Self, Items<Iterator.Element>>! { get set }
    var onDidRemoveItems: MulticastEvent<Self, Items<Iterator.Element>>! { get set }
    var onDidChangeItems: MulticastEvent<Self, Items<Iterator.Element>>! { get set }

    var onBatchUpdate: MulticastEvent<Self, UpdatePhase>! { get set }
    
    func batchUpdate(_ updateClosure: @noescape () -> ())
}

extension ObservableCollection where Self.Index == Int {
    public func batchUpdate(_ updateClosure: @noescape () -> ()) {
        onBatchUpdate.fire(.begin)
        updateClosure()
        onBatchUpdate.fire(.end)
    }
    
    func initEvents() {
        onDidChangeItems = MulticastEvent(context: self)
        onDidInsertItems = MulticastEvent(context: self)
        onDidRemoveItems = MulticastEvent(context: self)
        onBatchUpdate = MulticastEvent(context: self)
    }
    
    func fireChangeItem(_ index: Int) {
        fireChangeItems(index..<(index + 1))
    }
    
    func fireInsertItem(_ index: Int) {
        fireInsertItems(index..<(index + 1))
    }
    
    func fireRemoveItem(_ item: Iterator.Element, atIndex index: Int) {
        fireRemoveItems([item], bounds: index..<(index + 1))
    }
    
    func fireChangeItems(_ bounds: Range<Int>) {
        if bounds.isEmpty { return }
        onDidChangeItems.fire(Items(base: self, bounds: bounds))
    }
    
    func fireInsertItems(_ bounds: Range<Int>) {
        if bounds.isEmpty { return }
        onDidInsertItems.fire(Items(base: self, bounds: bounds))
    }
    
    func fireRemoveItems<C: Collection where C.Iterator.Element == Self.Iterator.Element, C.Index == Int>(_ items: C, bounds: Range<Int>) {
        if bounds.isEmpty { return }
        onDidRemoveItems.fire(Items(base: items, bounds: bounds))
    }
}

extension ObservableCollection where Self: CollectionWrapper, Self.Base.Index == Int, Self.Index == Int, Self.Iterator.Element == Self.Base.Iterator.Element {
    
    func oc_replaceRange(_ bounds: Range<Base.Index>, mutator: @noescape () -> ()) {
        let toRemove = Items(base: innerCollection, bounds: bounds)
        let oldEndIndex = endIndex
        
        mutator()
        
        batchUpdate {
            if !toRemove.isEmpty {
                onDidRemoveItems.fire(toRemove)
            }
            
            let dst = distance(from: oldEndIndex, to: endIndex)
            let countableBounds = CountableRange(bounds)
            let newEndIndex2 = index(countableBounds.endIndex, offsetBy: dst)
            let insertRange: Range = countableBounds.startIndex..<newEndIndex2
            
            fireInsertItems(insertRange)
        }
    }
}

extension ObservableCollection where Self: MutableCollectionWrapper, Self.Base.Index == Int, Self.Index == Int {

    func oc_setValue(_ value: Base.Iterator.Element, atPosition position: Base.Index) {
        innerCollection[position] = value
        fireChangeItem(position)
    }
}

extension ObservableCollection where Self: RangeReplaceableCollectionWrapper, Self.Index == Self.Base.Index, Self.Index == Int, Self.Iterator.Element == Self.Base.Iterator.Element {

    public func replaceRange<C: Collection where C.Iterator.Element == Iterator.Element>(_ subRange: Range<Index>, with newElements: C) {
        oc_replaceRange(subRange) {
            innerCollection.replaceSubrange(subRange, with: newElements)
        }
    }
    
    // Original implementation just call append number of times, so we need to override it.
    public func appendContentsOf<C: Collection where C.Iterator.Element == Iterator.Element>(_ newElements: C) {
        replaceRange(endIndex..<endIndex, with: newElements)
    }
    
    // Original implementation recreates instance, so we need to override it.
    public func removeAll(keepCapacity: Bool) {
        let toRemove = Items(base: innerCollection, bounds: innerCollection.startIndex..<innerCollection.endIndex)
        innerCollection.removeAll(keepingCapacity: keepCapacity)
        onDidRemoveItems.fire(toRemove)
    }
}

// It is like a Slice but don't keep base collection alive.
public struct Items<Element> : Collection, CustomDebugStringConvertible {
    
    let data: [Element]
    let bounds: CountableRange<Int>
    let offset: Int
    
    public var startIndex: Int {
        return bounds.startIndex
    }
    
    public var endIndex: Int {
        return bounds.endIndex
    }
    
    public subscript (index: Int) -> Element {
        return data[index - offset]
    }
    
    public subscript (bounds: Range<Int>) -> Slice<[Element]> {
        fatalError("Not implemented")
    }
    
    public init<C: Collection where C.Index == Int, C.Iterator.Element == Element>(base: C, bounds: Range<Int>) {
        if base.isEmpty && bounds.count > 0 {
            fatalError("Non empty bounds for empty collection.")
        }
        
        self.bounds = CountableRange(bounds)
        offset = bounds.lowerBound - base.startIndex
        
        var temp = base.isEmpty ? [] : [Element](repeating: base.first!, count: bounds.count)
        for idx in self.bounds {
            temp[idx - offset] = base[idx]
        }
        data = temp
    }
    
    public var debugDescription: String {
        return "\(bounds) elements \(data)"
    }
    
    public func index(after i: Int) -> Int {
        return bounds.index(after: i)
    }
}
