//
//  TableViewDictionaryAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public class TableViewDictionaryAdapter<K: Hashable, T: AnyObject>: TableViewSinglePartAdapter<ObservableOrderedMultiDictionary<K, T>> {
    
    public override init(tableView: UITableView, rowHeightMode: TableAdapterRowHeightModes) {
        super.init(tableView: tableView, rowHeightMode: rowHeightMode)
    }
    
    override func numberOfSections(tableView: UITableView) -> Int {
        return data.count
    }
    
    override func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        return data[section].1.count
    }
    
    override func viewModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return data[indexPath.section].1[indexPath.row]
    }
    
    override func beginListeningForData() {
        super.beginListeningForData()
        
        data.onDidInsertSubItems.register(tag, listener: handleSubItemsInserted)
        data.onDidRemoveSubItems.register(tag, listener: handleSubItemsRemoved)
        data.onDidChangeSubItems.register(tag, listener: handleSubItemsChanged)
    }
    
    override func stopListeningForData() {
        super.stopListeningForData()
        
        data.onDidInsertSubItems.unregister(tag)
        data.onDidRemoveSubItems.unregister(tag)
        data.onDidChangeSubItems.unregister(tag)
    }
    
    override func handleItemsChanged(sender: ObservableOrderedMultiDictionary<K, T>, items: [(K, ObservableArray<T>)], range: Range<Int>) {
        let set = indexSetOf(range)
        tableView.reloadSections(set, withRowAnimation: .Left)
        //onCellsReloaded?(self, paths)
    }
    
    override func handleItemsInserted(sender: ObservableOrderedMultiDictionary<K, T>, items: [(K, ObservableArray<T>)], range: Range<Int>) {
        let set = indexSetOf(range)
        tableView.insertSections(set, withRowAnimation: .Right)
        //onCellsInserted?(self, paths)
    }
    
    override func handleItemsRemoved(sender: ObservableOrderedMultiDictionary<K, T>, items: [(K, ObservableArray<T>)], range: Range<Int>) {
        let set = indexSetOf(range)
        tableView.deleteSections(set, withRowAnimation: .Middle)
        //onCellsRemoved?(self, paths)
    }
    
    func handleSubItemsInserted(sender: ObservableOrderedMultiDictionary<K, T>, items: [(T, Int, Int)]) {
        let paths = pathsOf(items)
        tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Right)
        onCellsInserted?(self, paths)
    }
    
    func handleSubItemsRemoved(sender: ObservableOrderedMultiDictionary<K, T>, items: [(T, Int, Int)]) {
        let paths = pathsOf(items)
        tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Middle)
        onCellsRemoved?(self, paths)
    }
    
    func handleSubItemsChanged(sender: ObservableOrderedMultiDictionary<K, T>, items: [(T, Int, Int)]) {
        let paths = pathsOf(items)
        tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .Left)
        onCellsReloaded?(self, paths)
    }
    
    func pathsOf(items: [(T, Int, Int)]) -> [NSIndexPath] {
        var result: [NSIndexPath] = []
        for (item, sec, row) in items {
            result.append(NSIndexPath(forRow: row, inSection: sec))
        }
        return result
    }
    
    func indexSetOf(range: Range<Int>) -> NSIndexSet {
        var result = NSMutableIndexSet()
        for idx in range {
            result.addIndex(idx)
        }
        return result
    }
}