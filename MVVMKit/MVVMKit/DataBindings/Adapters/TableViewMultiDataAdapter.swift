//
//  TableViewMultiDataAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public class TableViewMultiDataAdapter: TableViewBaseAdapter {
    
    // todo: use dictionary to support empty sections
    var items: ObservableArray<TableViewMultiDataAdapterItem> = []
    var headers: ObservableOrderedDictionary<Int, TableViewMultiDataAdapterSection> = [:]
    var footers: ObservableOrderedDictionary<Int, TableViewMultiDataAdapterSection> = [:]
    
    override public init(tableView: UITableView) {
        super.init(tableView: tableView)
        
        items.onDidInsertRange.register(tag) { [unowned self] in
            let set = self.indexSetOf($1.1)
            self.tableView.insertSections(set, withRowAnimation: .Right)
        }
        
        items.onDidRemoveRange.register(tag) { [unowned self] in
            let set = self.indexSetOf($1.1)
            self.tableView.deleteSections(set, withRowAnimation: .Left)
        }
        
        items.onDidChangeRange.register(tag) { [unowned self] in
            let set = self.indexSetOf($1.1)
            self.tableView.reloadSections(set, withRowAnimation: .Middle)
        }
        
        items.onBatchUpdate.register(tag) { [unowned self] in
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
    
    public func changeData<T: AnyObject>(data: T, forSection sIndex: Int) {
        items[sIndex].dispose()
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
        items[sIndex].dispose()
        items[sIndex] = createCollectionItem(data: data)
    }
    
    /// One-to-Any
    
    public func hasDataForSection(sIndex: Int) -> Bool {
        return items.count > sIndex
    }
    
    public func removeDataForSection(sIndex: Int) {
        items[sIndex].dispose()
        items.removeAtIndex(sIndex)
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
        return SimpleItem(data: data)
    }
    
    func createCollectionItem<T: AnyObject>(#data: ObservableArray<T>) -> TableViewMultiDataAdapterItem {
        return CollectionItem(data: data,
            onDidInsert: unowned(self, TableViewMultiDataAdapter.handleDidInsertItems),
            onDidRemove: unowned(self, TableViewMultiDataAdapter.handleDidRemoveItems),
            onDidChange: unowned(self, TableViewMultiDataAdapter.handleDidChangeItems),
            onBatchUpdate: unowned(self, TableViewMultiDataAdapter.handleItemsBatchUpdate))
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
    
    func dispose()
}

struct SimpleItem<T: AnyObject>: TableViewMultiDataAdapterItem {
    let data: T
    
    let id: String = NSUUID().UUIDString
    let count = 1
    
    func getDataAtIndex(index: Int) -> AnyObject {
        return data
    }
    
    func dispose() {
        
    }
}

struct CollectionItem<T: AnyObject>: TableViewMultiDataAdapterItem {
    let tag = "CollectionItem<T: AnyObject>"
    
    let data: ObservableArray<T>
    let id: String
    
    init(data: ObservableArray<T>, onDidInsert: ((String, [Int]) -> ()), onDidRemove: ((String, [Int]) -> ()), onDidChange: ((String, [Int]) -> ()), onBatchUpdate: ((String, UpdatePhase) -> ())) {
        let uuid = NSUUID().UUIDString
        
        id = uuid
        self.data = data
        
        self.data.onDidChangeRange.register(tag) {
            onDidChange(uuid, Array($1.1))
        }
        self.data.onDidInsertRange.register(tag) {
            onDidInsert(uuid, Array($1.1))
        }
        self.data.onDidRemoveRange.register(tag) {
            onDidRemove(uuid, Array($1.1))
        }
        self.data.onBatchUpdate.register(tag) {
            onBatchUpdate(uuid, $1)
        }
    }
    
    var count: Int {
        return data.count
    }
    
    func getDataAtIndex(index: Int) -> AnyObject {
        return data[index]
    }
    
    func dispose() {
        data.onDidChangeRange.unregister(tag)
        data.onDidInsertRange.unregister(tag)
        data.onDidRemoveRange.unregister(tag)
        data.onBatchUpdate.unregister(tag)
        
        println("destroyed \(id)")
    }
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
