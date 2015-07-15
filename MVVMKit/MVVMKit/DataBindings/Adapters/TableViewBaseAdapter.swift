//
//  TableViewBaseAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public class TableViewBaseAdapter: UITableViewSwiftDataSource, UITableViewSwiftDelegate {
    public typealias CellBinding = (AnyObject, NSIndexPath) -> UITableViewCell?
    public typealias CellsChangedEvent = (TableViewBaseAdapter, [NSIndexPath]) -> ()
    public typealias CellAction = (UITableViewCell, NSIndexPath) -> ()
    public typealias SectionBinding = (AnyObject) -> UIView?
    
    let tag = "observable_array_tag"
    
    // Workaround: anowned(safe) cause random crashes for NSObject descendants
    unowned(unsafe) let tableView: UITableView
    var cellBindings = [CellBinding]()
    var headerBindings = [SectionBinding]()
    var footerBindings = [SectionBinding]()
    
    lazy var dsProxy: UITableViewDataSourceProxy = { [unowned self] in
        UITableViewDataSourceProxy(dataSource: self)
        }()
    
    lazy var dProxy: UITableViewDelegateProxy = { [unowned self] in
        UITableViewDelegateProxy(swiftDelegate: self)
        }()
    
    var updateCounter = 0
    
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
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        self.tableView.dataSource = dsProxy
        self.tableView.delegate = dProxy
    }
    
    //public init(tableView: UITableView, sourceSignal: Signal<[T], NoError>)
    
    public func registerCell<CellType: UITableViewCell where CellType: BindableCellView, CellType: ViewForViewModel>(cellType: CellType.Type) {
        let binding = createCellBinding(cellType)
        cellBindings.append(binding)
    }
    
    public func registerHeader<HeaderType: UIView where HeaderType: ViewForViewModel>(headerType: HeaderType.Type) {
        let binding = createSectionBinding(headerType)
        headerBindings.append(binding)
    }
    
    public func registerFooter<HeaderType: UIView where HeaderType: ViewForViewModel>(headerType: HeaderType.Type) {
        let binding = createSectionBinding(headerType)
        footerBindings.append(binding)
    }
    
    func createCellBinding<CellType: UITableViewCell where CellType: BindableCellView>(cellType: CellType.Type) -> (viewModel: AnyObject, indexPath: NSIndexPath) -> UITableViewCell? {
        return { [unowned self] viewModel, indexPath in
            if let vm = viewModel as? CellType.ViewModelType {
                let cell = self.tableView.dequeueReusableCellWithIdentifier(CellType.CellIdentifier, forIndexPath: indexPath) as! CellType
                cell.viewModel = vm
                self.onWillBindCell?(cell, indexPath)
                cell.bindToViewModel()
                self.onCellBinded?(cell, indexPath)
                return cell
            }
            return nil
        }
    }
    
    func createSectionBinding<ViewType: UIView where ViewType: ViewForViewModel>(viewTypeType: ViewType.Type)(viewModel: AnyObject) -> UIView? {
        if let vm = viewModel as? ViewType.ViewModelType {
            let view = ViewType()
            view.viewModel = vm
            view.bindToViewModel()
            return view
        }
        return nil
    }
    
    func numberOfSections(tableView: UITableView) -> Int {
        fatalError("Abstract method")
    }
    
    func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        fatalError("Abstract method")
    }
    
    func cellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel: AnyObject = viewModelForIndexPath(indexPath)
        for bind in cellBindings {
            if let cell = bind(viewModel, indexPath) {
                return cell
            }
        }
        fatalError("Unknown View Model type.")
    }
    
    func viewModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        fatalError("Abstract method")
    }
    
    func titleForHeader(tableView: UITableView, section: Int) -> String? {
        return nil
    }
    
    func titleForFooter(tableView: UITableView, section: Int) -> String? {
        return nil
    }
    
    func viewForHeader(tableView: UITableView, section: Int) -> UIView? {
        return nil
    }
    
    func viewForFooter(tableView: UITableView, section: Int) -> UIView? {
        return nil
    }
    
    func heightForHeader(tableView: UITableView, section: Int) -> CGFloat {
        return 0
    }
    
    func heightForFooter(tableView: UITableView, section: Int) -> CGFloat {
        return 0
    }
    
    func didSelectRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) {
        
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
    
    public var onWillBindCell: CellAction?
    public var onCellBinded: CellAction?
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
}