//
//  ObservableCollection.swift
//  MVVMKit
//
//  Created by Евгений Губин on 20.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public struct RangeOf<T> {
    typealias Changed = ([T], Range<Int>)
}

public protocol ObservableCollection: class {
    typealias ItemType
    
    var onDidInsertRange: MulticastEvent<Self, RangeOf<ItemType>.Changed>! { get set }
    var onDidRemoveRange: MulticastEvent<Self, RangeOf<ItemType>.Changed>! { get set }
    var onDidChangeRange: MulticastEvent<Self, RangeOf<ItemType>.Changed>! { get set }
    
    var onBatchUpdate: MulticastEvent<Self, UpdatePhase>! { get set }
    
    init(data: [ItemType])
}

public func batchUpdate<T: ObservableCollection>(c: T, updateLogic: () -> ()) {
    c.onBatchUpdate.fire(.Begin)
    updateLogic()
    c.onBatchUpdate.fire(.End)
}