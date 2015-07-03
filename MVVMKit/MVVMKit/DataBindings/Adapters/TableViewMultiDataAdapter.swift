//
//  TableViewMultiDataAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public class TableViewMultiDataAdapter: TableViewBaseAdapter {
    
    var items: ObservableArray<TableViewMultiDataAdapterItem> = []
    var headers: ObservableOrderedDictionary<Int, TableViewMultiDataAdapterSection> = [:]
    var footers: ObservableOrderedDictionary<Int, TableViewMultiDataAdapterSection> = [:]
    
    override public init(tableView: UITableView) {
        super.init(tableView: tableView)
        
        items.onDidInsertRange.register(tag) {
            let set = self.indexSetOf($1.1)
            self.tableView.insertSections(set, withRowAnimation: .Right)
        }
        
        items.onDidRemoveRange.register(tag) {
            let set = self.indexSetOf($1.1)
            self.tableView.deleteSections(set, withRowAnimation: .Left)
        }
        
        items.onDidChangeRange.register(tag) {
            let set = self.indexSetOf($1.1)
            self.tableView.reloadSections(set, withRowAnimation: .Middle)
        }
        
        items.onBatchUpdate.register(tag) {
            self.batchUpdate($1)
        }
    }
    
    /// One-to-One
    
    public func addData<T: AnyObject>(data: T) {
        insertData(data, forSection: items.count)
    }
    
    public func insertData<T: AnyObject>(data: T, forSection sIndex: Int) {
        items.insert(createSimpleItem(data: data), atIndex: sIndex)
    }
    
    public func removeDataForSection(sIndex: Int) {
        items.removeAtIndex(sIndex)
    }
    
    public func changeData<T: AnyObject>(data: T, forSection sIndex: Int) {
        items[sIndex] = createSimpleItem(data: data)
    }
    
    /// One-to-Many
    
    public func addData<T: AnyObject>(data: ObservableArray<T>) {
        insertData(data, forSection: items.count)
    }
    
    public func insertData<T: AnyObject>(data: ObservableArray<T>, forSection sIndex: Int) {
        items.insert(createCollectionItem(data: data), atIndex: sIndex)
    }
    
    public func changeData<T: AnyObject>(data: ObservableArray<T>, forSection sIndex: Int) {
        items[sIndex] = createCollectionItem(data: data)
    }
    
    /// Section headers
    
    public func setTitle(title: String, forSectionHeader sIndex: Int) {
        headers[sIndex] = TableViewMultiDataAdapterSimpleSection(title: title)
    }
    
    public func setData(data: AnyObject, forSectionHeader sIndex: Int) {
        headers[sIndex] = TableViewMultiDataAdapterCustomViewSection(viewModel: data)
    }
    
    public func removeSectionHeader(sIndex: Int) {
        headers[sIndex] = nil
    }
    
    /// Section footers
    
    public func setTitle(title: String, forSectionFooter sIndex: Int) {
        footers[sIndex] = TableViewMultiDataAdapterSimpleSection(title: title)
    }
    
    public func setData(data: AnyObject, forSectionFooter sIndex: Int) {
        footers[sIndex] = TableViewMultiDataAdapterCustomViewSection(viewModel: data)
    }
    
    public func removeSectionFooters(sIndex: Int) {
        headers[sIndex] = nil
    }
    
    /// Implementation details
    
    override func numberOfSections(tableView: UITableView) -> Int {
        return items.count
    }
    
    override func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        return items[section].count
    }
    
    override func viewModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return items[indexPath.section].getDataAtIndex(indexPath.row)
    }
    
    override func titleForHeader(tableView: UITableView, section: Int) -> String? {
        return headers[section]?.title
    }
    
    override func titleForFooter(tableView: UITableView, section: Int) -> String? {
        return footers[section]?.title
    }
    
    override func heightForHeader(tableView: UITableView, section: Int) -> CGFloat {
        return headers[section] != nil ? UITableViewAutomaticDimension : 0
    }
    
    override func heightForFooter(tableView: UITableView, section: Int) -> CGFloat {
        return footers[section] != nil ? UITableViewAutomaticDimension : 0
    }
    
    override func viewForHeader(tableView: UITableView, section: Int) -> UIView? {
        if let vm: AnyObject = headers[section]?.viewModel {
            for bind in headerBindings {
                if let view = bind(vm) {
                    return view
                }
            }
        }
        return nil
    }

    override func viewForFooter(tableView: UITableView, section: Int) -> UIView? {
        if let vm: AnyObject = footers[section]?.viewModel {
            for bind in headerBindings {
                if let view = bind(vm) {
                    return view
                }
            }
        }
        return nil
    }
    
    func indexSetOf(range: Range<Int>) -> NSIndexSet {
        return reduce(range, NSMutableIndexSet()) { set, index in
            set.addIndex(index)
            return set
        }
    }
    
    func indexPathsOf(itemId: String, idxs: [Int]) -> [NSIndexPath] {
        let section = find(map(items) { $0.id }, itemId)!
        return idxs.map { NSIndexPath(forRow: $0, inSection: section) }
    }
    
    func createSimpleItem<T: AnyObject>(#data: T) -> TableViewMultiDataAdapterItem {
        return SimpleItem(data: data, onDidInsert: handleDidInsertItems,
            onDidRemove: handleDidRemoveItems, onDidChange: handleDidChangeItems, onBatchUpdate: handleItemsBatchUpdate)
    }
    
    func createCollectionItem<T: AnyObject>(#data: ObservableArray<T>) -> TableViewMultiDataAdapterItem {
        return CollectionItem(data: data, onDidInsert: handleDidInsertItems,
            onDidRemove: handleDidRemoveItems, onDidChange: handleDidChangeItems, onBatchUpdate: handleItemsBatchUpdate)
    }
    
    func handleDidInsertItems(id: String, idxs: [Int]) {
        let paths = indexPathsOf(id, idxs: idxs)
        tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Right)
    }
    
    func handleDidRemoveItems(id: String, idxs: [Int]) {
        let paths = indexPathsOf(id, idxs: idxs)
        tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Right)
    }
    
    func handleDidChangeItems(id: String, idxs: [Int]) {
        let paths = indexPathsOf(id, idxs: idxs)
        tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .Right)
    }
    
    func handleItemsBatchUpdate(id: String, phase: UpdatePhase) {
        batchUpdate(phase)
    }
    
    func batchUpdate(phase: UpdatePhase) {
        switch phase {
        case .Begin:
            beginUpdate()
        case .End:
            endUpdate()
        }
    }
}

protocol TableViewMultiDataAdapterItem {
    var id: String { get }
    var count: Int { get }
    func getDataAtIndex(index: Int) -> AnyObject
    
    var onDidInsert: ((String, [Int]) -> ()) { get set }
    var onDidRemove: ((String, [Int]) -> ()) { get set }
    var onDidChange: ((String, [Int]) -> ()) { get set }
    var onBatchUpdate: ((String, UpdatePhase) -> ()) { get set }
}

struct SimpleItem<T: AnyObject>: TableViewMultiDataAdapterItem {
    let data: T
    
    let id: String = NSUUID().UUIDString
    let count = 1
    
    func getDataAtIndex(index: Int) -> AnyObject {
        return data
    }
    
    var onDidInsert: ((String, [Int]) -> ())
    var onDidRemove: ((String, [Int]) -> ())
    var onDidChange: ((String, [Int]) -> ())
    var onBatchUpdate: ((String, UpdatePhase) -> ())
}

struct CollectionItem<T: AnyObject>: TableViewMultiDataAdapterItem {
    let data: ObservableArray<T>
    let tag = "CollectionItem<T: AnyObject>"
    
    let id: String = NSUUID().UUIDString
    
    init(data: ObservableArray<T>, onDidInsert: ((String, [Int]) -> ()), onDidRemove: ((String, [Int]) -> ()), onDidChange: ((String, [Int]) -> ()), onBatchUpdate: ((String, UpdatePhase) -> ())) {
        self.data = data
        self.onDidInsert = onDidInsert
        self.onDidRemove = onDidRemove
        self.onDidChange = onDidChange
        self.onBatchUpdate = onBatchUpdate
        
        self.data.onDidChangeRange.register(tag) {
            self.onDidChange(self.id, Array($1.1))
        }
        self.data.onDidInsertRange.register(tag) {
            self.onDidInsert(self.id, Array($1.1))
        }
        self.data.onDidRemoveRange.register(tag) {
            self.onDidRemove(self.id, Array($1.1))
        }
        self.data.onBatchUpdate.register(tag) {
            self.onBatchUpdate(self.id, $1)
        }
    }
    
    var count: Int {
        return data.count
    }
    
    func getDataAtIndex(index: Int) -> AnyObject {
        return data[index]
    }
    
    var onDidInsert: ((String, [Int]) -> ())
    var onDidRemove: ((String, [Int]) -> ())
    var onDidChange: ((String, [Int]) -> ())
    var onBatchUpdate: ((String, UpdatePhase) -> ())
}

protocol TableViewMultiDataAdapterSection {
    var title: String? { get }
    var viewModel: AnyObject? { get }
}

struct TableViewMultiDataAdapterSimpleSection : TableViewMultiDataAdapterSection {
    var title: String?
    let viewModel: AnyObject? = nil
}

struct TableViewMultiDataAdapterCustomViewSection : TableViewMultiDataAdapterSection {
    let title: String? = nil
    var viewModel: AnyObject?
}
