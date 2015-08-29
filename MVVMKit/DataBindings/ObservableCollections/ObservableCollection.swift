//
//  ObservableCollection.swift
//  MVVMKit
//
//  Created by Евгений Губин on 20.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

//public struct OCEvents<C: ObservableCollection> {
//    public typealias RangeChanged = MulticastEvent<C, ([C.ItemType], Range<Int>)>
//}
//
//public protocol ObservableCollection: class {
//    typealias ItemType
//    
//    var onDidInsertRange: OCEvents<Self>.RangeChanged! { get set }
//    var onDidRemoveRange: OCEvents<Self>.RangeChanged! { get set }
//    var onDidChangeRange: OCEvents<Self>.RangeChanged! { get set }
//    
//    var onBatchUpdate: MulticastEvent<Self, UpdatePhase>! { get set }
//    
//    init(data: [ItemType])
//}
//
//public func batchUpdate<T: ObservableCollection>(c: T, updateLogic: () -> ()) {
//    c.onBatchUpdate.fire(.Begin)
//    updateLogic()
//    c.onBatchUpdate.fire(.End)
//}

public protocol ObservableCollection: class, CollectionType {
    typealias EventType = MulticastEvent<Self, Items<Generator.Element>>
    typealias BatchUpdateEventType = MulticastEvent<Self, UpdatePhase>
    
    // Using of typealias causes compiler crash in extension
    
    // Slice points to original collection, so it doesn't work for removing
    // Workaround: make copy of collection and pass that copy to slice. What about memory consumption?
    var onDidInsertItems: MulticastEvent<Self, Items<Generator.Element>>! { get set }
    var onDidRemoveItems: MulticastEvent<Self, Items<Generator.Element>>! { get set }
    var onDidChangeItems: MulticastEvent<Self, Items<Generator.Element>>! { get set }

    var onBatchUpdate: MulticastEvent<Self, UpdatePhase>! { get set }
    
    func batchUpdate(@noescape updateClosure: () -> ())
}

extension ObservableCollection where Self.Index == Int {
    public func batchUpdate(@noescape updateClosure: () -> ()) {
        onBatchUpdate.fire(.Begin)
        updateClosure()
        onBatchUpdate.fire(.End)
    }
    
    func initEvents() {
        onDidChangeItems = MulticastEvent(context: self)
        onDidInsertItems = MulticastEvent(context: self)
        onDidRemoveItems = MulticastEvent(context: self)
        onBatchUpdate = MulticastEvent(context: self)
    }
    
    func fireChangeItem(index: Int) {
        fireChangeItems(index...index)
    }
    
    func fireInsertItem(index: Int) {
        fireInsertItems(index...index)
    }
    
    func fireRemoveItem(item: Generator.Element, atIndex index: Int) {
        fireRemoveItems([item], bounds: index...index)
    }
    
    func fireChangeItems(bounds: Range<Int>) {
        if bounds.isEmpty { return }
        onDidChangeItems.fire(Items(base: self, bounds: bounds))
    }
    
    func fireInsertItems(bounds: Range<Int>) {
        if bounds.isEmpty { return }
        onDidInsertItems.fire(Items(base: self, bounds: bounds))
    }
    
    func fireRemoveItems<C: CollectionType where C.Generator.Element == Self.Generator.Element, C.Index == Int>(items: C, bounds: Range<Int>) {
        if bounds.isEmpty { return }
        onDidRemoveItems.fire(Items(base: items, bounds: bounds))
    }
}

extension ObservableCollection where Self: CollectionWrapper, Self.Base.Index == Int, Self.Index == Int, Self.Generator.Element == Self.Base.Generator.Element {
    
    func oc_replaceRange(bounds: Range<Base.Index>, @noescape mutator: () -> ()) {
        let toRemove = Items(base: innerCollection, bounds: bounds)
        let oldCount = count
        
        mutator()
        
        batchUpdate {
            if !toRemove.isEmpty {
                onDidRemoveItems.fire(toRemove)
            }
            let deltaCount = count - oldCount
            fireInsertItems(bounds.startIndex..<(bounds.endIndex + deltaCount))
        }
    }

}

extension ObservableCollection where Self: MutableCollectionWrapper, Self.Base.Index == Int, Self.Index == Int {

    func oc_setValue(value: Base.Generator.Element, atPosition position: Base.Index) {
        innerCollection[position] = value
        fireChangeItem(position)
    }
}

extension ObservableCollection where Self: RangeReplaceableCollectionWrapper, Self.Index == Self.Base.Index, Self.Index == Int, Self.Generator.Element == Self.Base.Generator.Element {

    public func replaceRange<C: CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Index>, with newElements: C) {
        oc_replaceRange(subRange) {
            innerCollection.replaceRange(subRange, with: newElements)
        }
    }
    
    // Original implementation recreates instance, so we need to override it.
    public func removeAll(keepCapacity keepCapacity: Bool) {
        let toRemove = Items(base: innerCollection, bounds: innerCollection.startIndex..<innerCollection.endIndex)
        innerCollection.removeAll(keepCapacity: keepCapacity)
        onDidRemoveItems.fire(toRemove)
    }
}

// It is like a Slice but don't keep base collection alive.
public struct Items<Element> : CollectionType, CustomDebugStringConvertible {
    
    let data: [Element]
    let bounds: Range<Int>
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
    
    public init<C: CollectionType where C.Index == Int, C.Generator.Element == Element>(base: C, bounds: Range<Int>) {
        if base.isEmpty && bounds.count > 0 {
            fatalError("Non empty bounds for empty collection.")
        }
        
        self.bounds = bounds
        offset = bounds.startIndex - base.startIndex
        
        var temp = base.isEmpty ? [] : [Element](count: bounds.count, repeatedValue: base.first!)
        for idx in bounds {
            temp[idx - offset] = base[idx]
        }
        data = temp
    }
    
    public var debugDescription: String {
        return "\(bounds) elements \(data)"
    }
}