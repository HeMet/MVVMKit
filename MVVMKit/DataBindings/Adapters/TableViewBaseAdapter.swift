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

public class TableViewBaseAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    public typealias CellsChangedEvent = (TableViewBaseAdapter, [NSIndexPath]) -> ()
    public typealias CellAction = (UITableViewCell, NSIndexPath) -> ()
    
    let tag = "observable_array_tag"
    let slHeightForRowAtIndexPath = Selector("tableView:heightForRowAtIndexPath:")
    
    // Workaround: anowned(safe) cause random crashes for NSObject descendants
    unowned(unsafe) let tableView: UITableView
    public let cells: CellViewBindingManager
    public let views = ViewBindingManager()
    public let rowHeightMode: TableAdapterRowHeightModes
    
    var updateCounter = 0
    var rowSizeCache: [NSIndexPath: CGSize] = [:]
    
    public weak var delegate: UITableViewDelegate? {
        didSet {
            tableView.delegate = nil
            tableView.delegate = self
        }
    }
    
    public convenience init(tableView: UITableView) {
        self.init(tableView: tableView, rowHeightMode: .Default)
    }
    
    public init(tableView: UITableView, rowHeightMode: TableAdapterRowHeightModes) {
        self.tableView = tableView
        self.rowHeightMode = rowHeightMode
        cells = CellViewBindingManager(tableView: tableView)
        
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        fatalError("Abstract method")
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Abstract method")
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let viewModel: AnyObject = viewModelForSectionHeaderAtIndex(section) {
            return views.bindViewModel(viewModel)
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let viewModel: AnyObject = viewModelForSectionFooterAtIndex(section) {
            return views.bindViewModel(viewModel)
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let hasTitle = self.tableView(tableView, titleForHeaderInSection: section) != nil
        let hasVM = viewModelForSectionHeaderAtIndex(section) != nil
        
        return hasTitle || hasVM ? UITableViewAutomaticDimension : 0
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let hasTitle = self.tableView(tableView, titleForFooterInSection: section) != nil
        let hasVM = viewModelForSectionFooterAtIndex(section) != nil
        
        return hasTitle || hasVM ? UITableViewAutomaticDimension : 0
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let width = rowSizeCache[indexPath]?.width ?? 0
        if width != tableView.bounds.width {
            rowSizeCache[indexPath] = cells.sizeForViewModel(viewModelForIndexPath(indexPath), atIndexPath: indexPath)
        }
        
        return rowSizeCache[indexPath]!.height
    }
    
    func invalidateRowHeightCache() {
        rowSizeCache = [:]
    }
    
    public func beginUpdate() {
        updateCounter++
        if updateCounter == 1 {
            tableView.beginUpdates()
        }
    }
    
    public func endUpdate() {
        precondition(updateCounter >= 0, "Batch update calls are unbalanced")
        updateCounter--
        if updateCounter == 0 {
            tableView.endUpdates()
            performDelayedActions()
        }
    }
    
    var delayedActions: [UITableView -> ()] = []
    
    public func performAfterUpdate(action: UITableView -> ()) {
        
        if updateCounter == 0 {
            action(tableView)
        } else {
            delayedActions.append(action)
        }
    }
    
    func performDelayedActions() {
        let actions = delayedActions
        
        delayedActions.removeAll(keepCapacity: false)
        
        for action in actions {
            action(tableView)
        }
    }
    
    deinit {
        print("deinit Adapter")
    }

    public var onCellsInserted: CellsChangedEvent?
    public var onCellsRemoved: CellsChangedEvent?
    public var onCellsReloaded: CellsChangedEvent?
    
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        let usesAutoLayoutHeight = rowHeightMode == .Automatic || rowHeightMode == .Default
        
        if usesAutoLayoutHeight && aSelector == slHeightForRowAtIndexPath {
            return false
        }
        
        if let delegate = delegate where delegate.respondsToSelector(aSelector) {
            return true
        }
        return super.respondsToSelector(aSelector)
    }
    
    public override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        if let delegate = delegate where delegate.respondsToSelector(aSelector) {
            return delegate
        }
        return super.forwardingTargetForSelector(aSelector)
    }
}