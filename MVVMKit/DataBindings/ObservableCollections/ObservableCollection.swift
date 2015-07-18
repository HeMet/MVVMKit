//
//  ObservableCollection.swift
//  MVVMKit
//
//  Created by Евгений Губин on 20.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public struct OCEvents<C: ObservableCollection> {
    typealias RangeChanged = MulticastEvent<C, ([C.ItemType], Range<Int>)>
}

public protocol ObservableCollection: class {
    typealias ItemType
    
    var onDidInsertRange: OCEvents<Self>.RangeChanged! { get set }
    var onDidRemoveRange: OCEvents<Self>.RangeChanged! { get set }
    var onDidChangeRange: OCEvents<Self>.RangeChanged! { get set }
    
    var onBatchUpdate: MulticastEvent<Self, UpdatePhase>! { get set }
    
    init(data: [ItemType])
}

public func batchUpdate<T: ObservableCollection>(c: T, updateLogic: () -> ()) {
    c.onBatchUpdate.fire(.Begin)
    updateLogic()
    c.onBatchUpdate.fire(.End)
}