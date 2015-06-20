//
//  ObservableCollection.swift
//  MVVMKit
//
//  Created by Евгений Губин on 20.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public protocol ObservableCollection: class {
    typealias ItemType
    typealias RangeChangedEvent = MulticastEvent<Self, ([ItemType], Range<Int>)>
    typealias UpdatePhaseEvent = MulticastEvent<Self, UpdatePhase>
    
    var onDidInsertRange: RangeChangedEvent! { get }
    var onDidRemoveRange: RangeChangedEvent! { get }
    var onDidChangeRange: RangeChangedEvent! { get }
    
    var onBatchUpdate: UpdatePhaseEvent! { get }
}

public func batchUpdate<T: ObservableCollection>(c: T, updateLogic: () -> ()) {
    let event = c.onBatchUpdate as! MulticastEvent<T, UpdatePhase>
    event.fire(.Begin)
    updateLogic()
    event.fire(.End)
}