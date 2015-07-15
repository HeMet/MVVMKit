//
//  TableViewMultiDataAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public class TableViewMultiDataAdapter: TableViewBaseAdapter {
    
    var items: ObservableOrderedDictionary<Int, TableViewMultiDataAdapterItem> = [:]
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
    
    public func setData<T: AnyObject>(data: T, forSection sIndex: Int) {
        items[sIndex]?.dispose()
        items[sIndex] = createSimpleItem(data: data, section: sIndex)
    }
    
    /// One-to-Many
    
    public func setData<T: AnyObject>(data: ObservableArray<T>, forSection sIndex: Int) {
        items[sIndex]?.dispose()
        items[sIndex] = createCollectionItem(data: data, section: sIndex)
    }
    
    /// One-to-Any
    
    public func hasDataForSection(sIndex: Int) -> Bool {
        return items[sIndex] != nil
    }
    
    public func removeDataForSection(sIndex: Int) {
        items[sIndex]!.dispose()
        items[sIndex] = nil
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
        let idx = reduce(items.keys, -1, max)
        return items.count > 0 ? idx + 1 : 0
    }
    
    override func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        return items[section]?.count ?? 0
    }
    
    override func viewModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return items[indexPath.section]!.getDataAtIndex(indexPath.row)
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
    
    func indexPathsOf(section: Int, idxs: [Int]) -> [NSIndexPath] {
        return idxs.map { NSIndexPath(forRow: $0, inSection: section) }
    }
    
    func createSimpleItem<T: AnyObject>(#data: T, section: Int) -> TableViewMultiDataAdapterItem {
        return SimpleItem(data: data, section: section)
    }
    
    func createCollectionItem<T: AnyObject>(#data: ObservableArray<T>, section: Int) -> TableViewMultiDataAdapterItem {
        return CollectionItem(data: data, section: section,
            onDidInsert: unowned(self, TableViewMultiDataAdapter.handleDidInsertItems),
            onDidRemove: unowned(self, TableViewMultiDataAdapter.handleDidRemoveItems),
            onDidChange: unowned(self, TableViewMultiDataAdapter.handleDidChangeItems),
            onBatchUpdate: unowned(self, TableViewMultiDataAdapter.handleItemsBatchUpdate))
    }
    
    func handleDidInsertItems(section: Int, idxs: [Int]) {
        let paths = indexPathsOf(section, idxs: idxs)
        tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Right)
    }
    
    func handleDidRemoveItems(section: Int, idxs: [Int]) {
        let paths = indexPathsOf(section, idxs: idxs)
        tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Right)
    }
    
    func handleDidChangeItems(section: Int, idxs: [Int]) {
        let paths = indexPathsOf(section, idxs: idxs)
        tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .Right)
    }
    
    func handleItemsBatchUpdate(section: Int, phase: UpdatePhase) {
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
    var section: Int { get }
    var count: Int { get }
    func getDataAtIndex(index: Int) -> AnyObject
    
    func dispose()
}

struct SimpleItem<T: AnyObject>: TableViewMultiDataAdapterItem {
    let data: T
    
    let section: Int
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
    let section: Int
    
    init(data: ObservableArray<T>, section: Int, onDidInsert: ((Int, [Int]) -> ()), onDidRemove: ((Int, [Int]) -> ()), onDidChange: ((Int, [Int]) -> ()), onBatchUpdate: ((Int, UpdatePhase) -> ())) {

        self.section = section
        self.data = data
        
        self.data.onDidChangeRange.register(tag) {
            onDidChange(section, Array($1.1))
        }
        self.data.onDidInsertRange.register(tag) {
            onDidInsert(section, Array($1.1))
        }
        self.data.onDidRemoveRange.register(tag) {
            onDidRemove(section, Array($1.1))
        }
        self.data.onBatchUpdate.register(tag) {
            onBatchUpdate(section, $1)
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
