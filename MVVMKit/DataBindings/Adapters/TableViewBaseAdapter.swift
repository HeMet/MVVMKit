//
//  TableViewBaseAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public enum TableViewSectionView {
    case Header, Footer
}

public enum TableAdapterRowHeightModes {
    case Automatic, TemplateCell, Manual, Default
}

public class TableViewBaseAdapter: UITableViewSwiftDataSource, UITableViewSwiftDelegate {
    public typealias CellsChangedEvent = (TableViewBaseAdapter, [NSIndexPath]) -> ()
    public typealias CellAction = (UITableViewCell, NSIndexPath) -> ()
    
    let tag = "observable_array_tag"
    
    // Workaround: anowned(safe) cause random crashes for NSObject descendants
    unowned(unsafe) let tableView: UITableView
    public let cells: CellViewBindingManager
    public let views = ViewBindingManager()
    public let rowHeightMode: TableAdapterRowHeightModes
    
    lazy var dsProxy: UITableViewDataSourceProxy = { [unowned self] in
        UITableViewDataSourceProxy(dataSource: self)
        }()
    
    lazy var dProxy: UITableViewDelegateProxy = { [unowned self] in
        let r = UITableViewDelegateProxy(swiftDelegate: self)
        
        if self.rowHeightMode == .Automatic || self.rowHeightMode == .Default {
            r.selectorsToIgnore = ["tableView:heightForRowAtIndexPath:"]
        }
        
        return r
        }()
    
    var updateCounter = 0
    var rowHeightCache: [NSIndexPath: CGFloat] = [:]
    
    public var delegate: UITableViewDelegate? {
        get {
            return dProxy.delegate
        }
        set {
            dProxy.delegate = newValue
            self.tableView.delegate = nil
            self.tableView.delegate = dProxy
        }
    }
    
    public convenience init(tableView: UITableView) {
        self.init(tableView: tableView, rowHeightMode: .Default)
    }
    
    public init(tableView: UITableView, rowHeightMode: TableAdapterRowHeightModes) {
        self.tableView = tableView
        self.rowHeightMode = rowHeightMode
        cells = CellViewBindingManager(tableView: tableView)
        
        self.tableView.dataSource = dsProxy
        self.tableView.delegate = dProxy
    }
    
    //public init(tableView: UITableView, sourceSignal: Signal<[T], NoError>)
    
    func numberOfSections(tableView: UITableView) -> Int {
        fatalError("Abstract method")
    }
    
    func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        fatalError("Abstract method")
    }
    
    func cellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel: AnyObject = viewModelForIndexPath(indexPath)
        return cells.bindViewModel(viewModel, indexPath: indexPath)
    }
    
    func viewModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        fatalError("Abstract method")
    }
    
    func viewModelForSectionHeaderAtIndex(index: Int) -> AnyObject? {
        return nil
    }
    
    func viewModelForSectionFooterAtIndex(index: Int) -> AnyObject? {
        return nil
    }
    
    func titleForHeader(tableView: UITableView, section: Int) -> String? {
        return nil
    }
    
    func titleForFooter(tableView: UITableView, section: Int) -> String? {
        return nil
    }
    
    func viewForHeader(tableView: UITableView, section: Int) -> UIView? {
        if let viewModel: AnyObject = viewModelForSectionHeaderAtIndex(section) {
            return views.bindViewModel(viewModel)
        }
        return nil
    }
    
    func viewForFooter(tableView: UITableView, section: Int) -> UIView? {
        if let viewModel: AnyObject = viewModelForSectionFooterAtIndex(section) {
            return views.bindViewModel(viewModel)
        }
        return nil
    }
    
    func heightForHeader(tableView: UITableView, section: Int) -> CGFloat {
        let hasTitle = titleForHeader(tableView, section: section) != nil
        let hasVM = viewModelForSectionHeaderAtIndex(section) != nil
        
        return hasTitle || hasVM ? UITableViewAutomaticDimension : 0
    }
    
    func heightForFooter(tableView: UITableView, section: Int) -> CGFloat {
        let hasTitle = titleForFooter(tableView, section: section) != nil
        let hasVM = viewModelForSectionFooterAtIndex(section) != nil
        
        return hasTitle || hasVM ? UITableViewAutomaticDimension : 0
    }
    
    func didSelectRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) {
        
    }
    
    func heightForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> CGFloat {
        if rowHeightCache[indexPath] == nil {
            rowHeightCache[indexPath] = cells.heightForViewModel(viewModelForIndexPath(indexPath), atIndexPath: indexPath)
        }
        return rowHeightCache[indexPath]!
    }
    
    func invalidateRowHeightCache() {
        rowHeightCache = [:]
    }
    
    public func beginUpdate() {
        self.updateCounter++
        if (self.updateCounter == 1) {
            self.tableView.beginUpdates()
        }
    }
    
    public func endUpdate() {
        precondition(self.updateCounter >= 0, "Batch update calls are unbalanced")
        self.updateCounter--
        if (self.updateCounter == 0) {
            self.tableView.endUpdates()
            performDelayedActions()
        }
    }
    
    var delayedActions: [UITableView -> ()] = []
    
    public func performAfterUpdate(action: UITableView -> ()) {
        
        if self.updateCounter == 0 {
            action(self.tableView)
        } else {
            delayedActions.append(action)
        }
    }
    
    func performDelayedActions() {
        let actions = delayedActions
        
        delayedActions.removeAll(keepCapacity: false)
        
        for action in actions {
            action(self.tableView)
        }
    }
    
    deinit {
        println("deinit Adapter")
    }

    public var onCellsInserted: CellsChangedEvent?
    public var onCellsRemoved: CellsChangedEvent?
    public var onCellsReloaded: CellsChangedEvent?
}

protocol UITableViewSwiftDataSource: class {
    func numberOfSections(tableView: UITableView) -> Int
    func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int
    func cellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
    func titleForHeader(tableView: UITableView, section: Int) -> String?
    func titleForFooter(tableView: UITableView, section: Int) -> String?
}

@objc class UITableViewDataSourceProxy: NSObject, UITableViewDataSource {
    
    unowned var dataSource: UITableViewSwiftDataSource
    
    init(dataSource: UITableViewSwiftDataSource) {
        self.dataSource = dataSource
    }
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections(tableView)
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRowsInSection(tableView, section: section)
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dataSource.cellForRowAtIndexPath(tableView, indexPath: indexPath)
    }
    
    @objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeader(tableView, section: section)
    }
    
    @objc func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource.titleForFooter(tableView, section: section)
    }
}

protocol UITableViewSwiftDelegate: class {
    func viewForHeader(tableView: UITableView, section: Int) -> UIView?
    func viewForFooter(tableView: UITableView, section: Int) -> UIView?
    func heightForHeader(tableView: UITableView, section: Int) -> CGFloat
    func heightForFooter(tableView: UITableView, section: Int) -> CGFloat
    func didSelectRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath)
    func heightForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> CGFloat
}

@objc class UITableViewDelegateProxy: UITableViewDelegateForwarder {
    
    unowned var swiftDelegate: UITableViewSwiftDelegate
    
    init(swiftDelegate: UITableViewSwiftDelegate) {
        self.swiftDelegate = swiftDelegate
        super.init()
    }
    
    // nil means "use default stub view of non empty area"
    @objc override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return swiftDelegate.viewForHeader(tableView, section: section)
    }
    
    @objc override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return swiftDelegate.viewForFooter(tableView, section: section)
    }
    
    @objc override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return swiftDelegate.heightForHeader(tableView, section: section)
    }
    
    @objc override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return swiftDelegate.heightForFooter(tableView, section: section)
    }
    
    @objc override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return swiftDelegate.heightForRowAtIndexPath(tableView, indexPath: indexPath)
    }
}