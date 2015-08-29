//
//  TableViewMultiDataAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

public class TableViewAdapter: TableViewBaseAdapter, ObservableArrayListener {
    
    var items: ObservableOrderedDictionary<Int, TableViewSectionDataModel> = [:]
    var headers: ObservableOrderedDictionary<Int, TableViewSectionModel> = [:]
    var footers: ObservableOrderedDictionary<Int, TableViewSectionModel> = [:]
    
    override public init(tableView: UITableView, rowHeightMode: TableAdapterRowHeightModes) {
        super.init(tableView: tableView, rowHeightMode: rowHeightMode)
        
        items.onDidInsertItems.register(tag) { [unowned self] in
            self.invalidateRowHeightCache()
            
            self.tableView.insertSections($1.getIndexSet(), withRowAnimation: .Right)
        }
        
        items.onDidRemoveItems.register(tag) { [unowned self] in
            self.invalidateRowHeightCache()
            
            self.tableView.deleteSections($1.getIndexSet(), withRowAnimation: .Left)
        }
        
        items.onDidChangeItems.register(tag) { [unowned self] in
            self.invalidateRowHeightCache()
            
            self.tableView.reloadSections($1.getIndexSet(), withRowAnimation: .Middle)
        }
        
        items.onBatchUpdate.register(tag) { [unowned self] in
            self.batchUpdate($1)
        }
    }
    
    deinit {
        disposeItems()
    }
    
    func disposeItems() {
        // Workaround: Enumeration on items itself cause compiler to crash.
        for key in items.keys {
//            items[key]!.dispose()
            items.getValueForKey(key)!.dispose()
        }
    }
    
    /// One-to-One
    
    public func setData<T: AnyObject>(data: T, forSectionAtIndex sIndex: Int) {
//        items[sIndex]?.dispose()
        items.getValueForKey(sIndex)?.dispose()
        items[sIndex] = SimpleItem(data: data)
    }
    
    /// One-to-Many
    
    public func setData<T: AnyObject>(data: ObservableArray<T>, forSectionAtIndex sIndex: Int) {
//        items[sIndex]?.dispose()
        items.getValueForKey(sIndex)?.dispose()
        data.bindToSection(sIndex, listener: self)
        items[sIndex] = data
    }
    
    /// One-to-Any
    
    public func hasDataForSection(sIndex: Int) -> Bool {
//        return items[sIndex] != nil
        return items.getValueForKey(sIndex) != nil
    }
    
    public func removeDataForSection(sIndex: Int) {
//        items[sIndex]!.dispose()
        items.getValueForKey(sIndex)!.dispose()
        items[sIndex] = nil
    }
    
    /// Section header & footers
    
    public func setTitle(title: String, forSection: TableViewSectionView, atIndex: Int) {
        let models = getModelsForSectionView(forSection)
        models[atIndex] = TableViewSimpleSection(title: title)
    }
    
    public func setData(data: AnyObject, forSection: TableViewSectionView, atIndex: Int) {
        let models = getModelsForSectionView(forSection)
        models[atIndex] = TableViewCustomViewSection(viewModel: data)
    }
    
    public func removeSectionView(sectionView: TableViewSectionView, atIndex: Int) {
        let models = getModelsForSectionView(sectionView)
        models[atIndex] = nil
    }
    
    /// Implementation details
    
    func getModelsForSectionView(sv: TableViewSectionView) -> ObservableOrderedDictionary<Int, TableViewSectionModel> {
        return sv == .Header ? headers : footers
    }
    
    override func numberOfSections(tableView: UITableView) -> Int {
        let idx = items.keys.reduce(-1, combine: max)
        return items.count > 0 ? idx + 1 : 0
    }
    
    override func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
//        return items[section]?.count ?? 0
        return items.getValueForKey(section)?.count ?? 0
    }
    
    override func viewModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
//        return items[indexPath.section]!.getDataAtIndex(indexPath.row)
        return items.getValueForKey(indexPath.section)!.getDataAtIndex(indexPath.row)
    }
    
    override func viewModelForSectionHeaderAtIndex(index: Int) -> AnyObject? {
        return headers.getValueForKey(index)?.viewModel
//        return headers[index]?.viewModel
    }

    override func viewModelForSectionFooterAtIndex(index: Int) -> AnyObject? {
        return footers.getValueForKey(index)?.viewModel
//        return footers[index]?.viewModel
    }
    
    override func titleForHeader(tableView: UITableView, section: Int) -> String? {
//        return headers[section]?.title
        return headers.getValueForKey(section)?.title
    }
    
    override func titleForFooter(tableView: UITableView, section: Int) -> String? {
//        return footers[section]?.title
        return footers.getValueForKey(section)?.title
    }
    
    func handleDidInsertItems(paths: [NSIndexPath]) {
        self.invalidateRowHeightCache()
        
        tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Right)
        onCellsInserted?(self, paths)
    }
    
    func handleDidRemoveItems(paths: [NSIndexPath]) {
        self.invalidateRowHeightCache()
        
        tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Right)
        onCellsRemoved?(self, paths)
    }
    
    func handleDidChangeItems(paths: [NSIndexPath]) {
        self.invalidateRowHeightCache()
        
        tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .Right)
        onCellsReloaded?(self, paths)
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

protocol TableViewSectionDataModel {
    var count: Int { get }
    func getDataAtIndex(index: Int) -> AnyObject
    func dispose()
}

protocol ObservableArrayListener: class {
    func handleDidInsertItems(paths: [NSIndexPath])
    func handleDidRemoveItems(paths: [NSIndexPath])
    func handleDidChangeItems(paths: [NSIndexPath])
    func handleItemsBatchUpdate(section: Int, phase: UpdatePhase)
}

// AnyObject is a protocol hence we cann't extend it to support TableViewMultiDataAdapterItem
struct SimpleItem<T: AnyObject>: TableViewSectionDataModel {
    let data: T
    
    let count = 1
    
    func getDataAtIndex(index: Int) -> AnyObject {
        return data
    }
    
    func dispose() {
        
    }
}

extension ObservableArray: TableViewSectionDataModel {
    var tag: String {
        return "CollectionItem<T: AnyObject>"
    }
    
    func getDataAtIndex(index: Int) -> AnyObject {
        // there is no way in Swift 1.2 to specify extenstion for array of objects only
        return self[index] as! AnyObject
    }
    
    func bindToSection(section: Int, listener: ObservableArrayListener) {
        onDidChangeItems.register(tag) { [unowned listener] in
            listener.handleDidChangeItems($1.getPathsForSection(section))
        }
        onDidInsertItems.register(tag) { [unowned listener] in
            listener.handleDidInsertItems($1.getPathsForSection(section))
        }
        onDidRemoveItems.register(tag) { [unowned listener] in
            listener.handleDidRemoveItems($1.getPathsForSection(section))
        }
        onBatchUpdate.register(tag) { [unowned listener] in
            listener.handleItemsBatchUpdate(section, phase: $1)
        }
    }
    
    func dispose() {
        onDidChangeItems.unregister(tag)
        onDidInsertItems.unregister(tag)
        onDidRemoveItems.unregister(tag)
        onBatchUpdate.unregister(tag)
    }
}

protocol TableViewSectionModel {
    var title: String? { get }
    var viewModel: AnyObject? { get }
}

struct TableViewSimpleSection : TableViewSectionModel {
    var title: String?
    let viewModel: AnyObject? = nil
}

struct TableViewCustomViewSection : TableViewSectionModel {
    let title: String? = nil
    var viewModel: AnyObject?
}

extension Indexable where Index == Int {
    func getIndexSet() -> NSMutableIndexSet {
        return (startIndex..<endIndex).reduce(NSMutableIndexSet()) { set, index in
            set.addIndex(index)
            return set
        }
    }
    
    func getPathsForSection(section: Int) -> [NSIndexPath] {
        return (startIndex..<endIndex).map { NSIndexPath(forRow: $0, inSection: section) }
    }
}