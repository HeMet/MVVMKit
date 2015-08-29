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

public class TableViewBaseAdapter: NSObject, UITableViewDataSource, UITableViewSwiftDelegate {
    public typealias CellsChangedEvent = (TableViewBaseAdapter, [NSIndexPath]) -> ()
    public typealias CellAction = (UITableViewCell, NSIndexPath) -> ()
    
    let tag = "observable_array_tag"
    
    // Workaround: anowned(safe) cause random crashes for NSObject descendants
    unowned(unsafe) let tableView: UITableView
    public let cells: CellViewBindingManager
    public let views = ViewBindingManager()
    public let rowHeightMode: TableAdapterRowHeightModes
    
    lazy var dProxy: UITableViewDelegateProxy = { [unowned self] in
        let r = UITableViewDelegateProxy(swiftDelegate: self)
        
        if self.rowHeightMode == .Automatic || self.rowHeightMode == .Default {
            r.selectorsToIgnore = ["tableView:heightForRowAtIndexPath:"]
        }
        
        return r
        }()
    
    var updateCounter = 0
    var rowSizeCache: [NSIndexPath: CGSize] = [:]
    
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
        
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = dProxy
    }
    
    //public init(tableView: UITableView, sourceSignal: Signal<[T], NoError>)
    
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
        let hasTitle = self.tableView(tableView, titleForHeaderInSection: section) != nil
        let hasVM = viewModelForSectionHeaderAtIndex(section) != nil
        
        return hasTitle || hasVM ? UITableViewAutomaticDimension : 0
    }
    
    func heightForFooter(tableView: UITableView, section: Int) -> CGFloat {
        let hasTitle = self.tableView(tableView, titleForFooterInSection: section) != nil
        let hasVM = viewModelForSectionFooterAtIndex(section) != nil
        
        return hasTitle || hasVM ? UITableViewAutomaticDimension : 0
    }
    
    func didSelectRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) {
        
    }
    
    func heightForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> CGFloat {
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
        self.updateCounter++
        if (self.updateCounter == 1) {
            self.tableView.beginUpdates()
        }
    }
    
    public func endUpdate() {
        precondition(updateCounter >= 0, "Batch update calls are unbalanced")
        self.updateCounter--
        if (updateCounter == 0) {
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