//
//  TableViewSinglePartAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public class TableViewSinglePartAdapter<T: ObservableCollection>: TableViewBaseAdapter {
    var data: T = T(data: [])
    
    public override init(tableView: UITableView) {
        super.init(tableView: tableView)
    }
    
    deinit {
        stopListeningForData()
    }
    
    public func setData(newData: [T.ItemType]) {
        let data = T(data: newData)
        setData(data)
    }
    
    public func setData(newData: T) {
        stopListeningForData()
        data = newData
        beginListeningForData()
        
        tableView.reloadData()
    }
    
    func beginListeningForData() {
        data.onDidInsertRange.register(tag) {
            self.handleItemsInserted($0, items: $1.0, range: $1.1)
        }
        
        data.onDidRemoveRange.register(tag) {
            self.handleItemsRemoved($0, items: $1.0, range: $1.1)
        }
        
        data.onDidChangeRange.register(tag) {
            self.handleItemsChanged($0, items: $1.0, range: $1.1)
        }
        
        data.onBatchUpdate.register(tag, listener: handleUpdatePhase)
    }
    
    func stopListeningForData() {
        data.onDidInsertRange.unregister(tag)
        data.onDidRemoveRange.unregister(tag)
        data.onDidChangeRange.unregister(tag)
        data.onBatchUpdate.unregister(tag)
    }
    
    func handleUpdatePhase(sender: T, phase: UpdatePhase) {
        switch phase {
        case .Begin:
            beginUpdate()
        case .End:
            endUpdate()
        }
    }
    
    func handleItemsChanged(sender: T, items: [T.ItemType], range: Range<Int>) {
        fatalError("Abstract method")    }
    
    func handleItemsInserted(sender: T, items: [T.ItemType], range: Range<Int>) {
        fatalError("Abstract method")
    }
    
    func handleItemsRemoved(sender: T, items: [T.ItemType], range: Range<Int>) {
        fatalError("Abstract method")
    }
    
    func pathsOf(itemIndexes: Range<Int>) -> [NSIndexPath] {
        return map(itemIndexes) {
            NSIndexPath(forRow: $0, inSection: 0)
        }
    }
}
