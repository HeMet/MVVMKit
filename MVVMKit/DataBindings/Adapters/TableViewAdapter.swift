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
            
            self.tableView.insertSections($1.getIndexSet(), with: .right)
        }
        
        items.onDidRemoveItems.register(tag) { [unowned self] in
            self.invalidateRowHeightCache()
            
            self.tableView.deleteSections($1.getIndexSet(), with: .left)
        }
        
        items.onDidChangeItems.register(tag) { [unowned self] in
            self.invalidateRowHeightCache()
            
            self.tableView.reloadSections($1.getIndexSet(), with: .middle)
        }
        
        items.onBatchUpdate.register(tag) { [unowned self] in
            self.batchUpdate($1)
        }
    }
    
    deinit {
        disposeItems()
    }
    
    func disposeItems() {
        for (_, v) in items {
            v.dispose()
        }
    }
    
    /// One-to-One
    
    public func setData<T: ViewModel>(_ data: T, forSectionAtIndex sIndex: Int) {
//        items[sIndex]?.dispose()
        items.getValueForKey(sIndex)?.dispose()
        items[sIndex] = AnyViewModel(viewModel: data)
    }
    
    /// One-to-Many
    
    public func setData<T: ViewModel>(_ data: ObservableArray<T>, forSectionAtIndex sIndex: Int) {
//        items[sIndex]?.dispose()
        items.getValueForKey(sIndex)?.dispose()
        let cdm = CollectionDataModel(collection: data)
        cdm.bindToSection(sIndex, listener: self)
        items[sIndex] = cdm
    }
    
    /// One-to-Any
    
    public func hasDataForSection(_ sIndex: Int) -> Bool {
//        return items[sIndex] != nil
        return items.getValueForKey(sIndex) != nil
    }
    
    public func removeDataForSection(_ sIndex: Int) {
//        items[sIndex]!.dispose()
        items.getValueForKey(sIndex)!.dispose()
        items[sIndex] = nil
    }
    
    /// Section header & footers
    
    public func setTitle(_ title: String, forSection: TableViewSectionView, atIndex: Int) {
        let models = getModelsForSectionView(forSection)
        models[atIndex] = TableViewSimpleSection(title: title)
    }
    
    public func setData<VM: ViewModel>(_ data: VM, forSection: TableViewSectionView, atIndex: Int) {
        let models = getModelsForSectionView(forSection)
        models[atIndex] = TableViewCustomViewSection(viewModel: !data)
    }
    
    public func removeSectionView(_ sectionView: TableViewSectionView, atIndex: Int) {
        let models = getModelsForSectionView(sectionView)
        models[atIndex] = nil
    }
    
    /// Implementation details
    
    func getModelsForSectionView(_ sv: TableViewSectionView) -> ObservableOrderedDictionary<Int, TableViewSectionModel> {
        return sv == .header ? headers : footers
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        let idx = items.keys.reduce(-1, combine: max)
        return items.count > 0 ? idx + 1 : 0
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items[section]?.count ?? 0
        return items.getValueForKey(section)?.count ?? 0
    }
    
    override func viewModelForIndexPath(_ indexPath: IndexPath) -> AnyViewModel {
//        return items[indexPath.section]!.getDataAtIndex(indexPath.row)
        return items.getValueForKey((indexPath as NSIndexPath).section)!.getDataAtIndex((indexPath as NSIndexPath).row)
    }
    
    override func viewModelForSectionHeaderAtIndex(_ index: Int) -> AnyViewModel? {
        return headers.getValueForKey(index)?.viewModel
//        return headers[index]?.viewModel
    }

    override func viewModelForSectionFooterAtIndex(_ index: Int) -> AnyViewModel? {
        return footers.getValueForKey(index)?.viewModel
//        return footers[index]?.viewModel
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return headers[section]?.title
        return headers.getValueForKey(section)?.title
    }
    
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return footers[section]?.title
        return footers.getValueForKey(section)?.title
    }
    
    func handleDidInsertItems(_ paths: [IndexPath]) {
        self.invalidateRowHeightCache()
        
        tableView.insertRows(at: paths, with: .right)
        onCellsInserted?(self, paths)
    }
    
    func handleDidRemoveItems(_ paths: [IndexPath]) {
        self.invalidateRowHeightCache()
        
        tableView.deleteRows(at: paths, with: .right)
        onCellsRemoved?(self, paths)
    }
    
    func handleDidChangeItems(_ paths: [IndexPath]) {
        self.invalidateRowHeightCache()
        
        tableView.reloadRows(at: paths, with: .right)
        onCellsReloaded?(self, paths)
    }
    
    func handleItemsBatchUpdate(_ section: Int, phase: UpdatePhase) {
        batchUpdate(phase)
    }
    
    func batchUpdate(_ phase: UpdatePhase) {
        switch phase {
        case .begin:
            beginUpdate()
        case .end:
            endUpdate()
        }
    }
}

protocol TableViewSectionDataModel {
    var count: Int { get }
    func getDataAtIndex(_ index: Int) -> AnyViewModel
    func dispose()
}

protocol ObservableArrayListener: class {
    func handleDidInsertItems(_ paths: [IndexPath])
    func handleDidRemoveItems(_ paths: [IndexPath])
    func handleDidChangeItems(_ paths: [IndexPath])
    func handleItemsBatchUpdate(_ section: Int, phase: UpdatePhase)
}

extension AnyViewModel: TableViewSectionDataModel {
    var count: Int {
        return 1
    }
    
    func getDataAtIndex(_ index: Int) -> AnyViewModel {
        return self
    }
    
    func dispose() {
        
    }
}

struct CollectionDataModel<T: ObservableCollection where T.Iterator.Element: ViewModel, T.Index == Int>: TableViewSectionDataModel {
    
    let tag = "CollectionItem<T: AnyObject>"
    
    let collection: T
    
    init(collection: T) {
        self.collection = collection
    }
    
    var count: Int {
        return collection.count
    }
    
    func getDataAtIndex(_ index: Int) -> AnyViewModel {
        return AnyViewModel(viewModel: collection[index])
    }
    
    func bindToSection(_ section: Int, listener: ObservableArrayListener) {
        collection.onDidChangeItems.register(tag) { [unowned listener] in
            listener.handleDidChangeItems($1.getPathsForSection(section))
        }
        collection.onDidInsertItems.register(tag) { [unowned listener] in
            listener.handleDidInsertItems($1.getPathsForSection(section))
        }
        collection.onDidRemoveItems.register(tag) { [unowned listener] in
            listener.handleDidRemoveItems($1.getPathsForSection(section))
        }
        collection.onBatchUpdate.register(tag) { [unowned listener] in
            listener.handleItemsBatchUpdate(section, phase: $1)
        }
    }
    
    func dispose() {
        collection.onDidChangeItems.unregister(tag)
        collection.onDidInsertItems.unregister(tag)
        collection.onDidRemoveItems.unregister(tag)
        collection.onBatchUpdate.unregister(tag)
    }
}

protocol TableViewSectionModel {
    var title: String? { get }
    var viewModel: AnyViewModel? { get }
}

struct TableViewSimpleSection : TableViewSectionModel {
    var title: String?
    let viewModel: AnyViewModel? = nil
}

struct TableViewCustomViewSection : TableViewSectionModel {
    let title: String? = nil
    var viewModel: AnyViewModel?
}

extension Indexable where Index == Int {
    func getIndexSet() -> IndexSet {
        return (startIndex..<endIndex).reduce(IndexSet()) { set, index in
            var copy = set
            copy.insert(index)
            return copy
        }
    }
    
    func getPathsForSection(_ section: Int) -> [IndexPath] {
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: section) }
    }
}
