//
//  TableViewBaseAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public class TableViewBaseAdapter {
    public typealias CellBinding = (AnyObject, NSIndexPath) -> UITableViewCell?
    public typealias CellsChangedEvent = (TableViewBaseAdapter, [NSIndexPath]) -> ()
    public typealias CellAction = (UITableViewCell, NSIndexPath) -> ()
    public typealias SectionBinding = (AnyObject) -> UIView?
    
    let tag = "observable_array_tag"
    
    let tableView: UITableView
    var cellBindings = [CellBinding]()
    var headerBindings = [SectionBinding]()
    var footerBindings = [SectionBinding]()
    lazy var dsProxy: UITableViewDataSourceProxy = { [unowned self] in
        var proxy = UITableViewDataSourceProxy(getCount: self.numberOfRowsInSection, getCell: self.cellForRowAtIndexPath)
        proxy.getSectionCount = self.numberOfSections
        proxy.getTitleForHeader = self.titleForHeader
        return proxy
        }()
    lazy var dProxy: UITableViewDelegateProxy = { [unowned self] in
        var proxy = UITableViewDelegateProxy(onSelect: self.didSelectRowAtIndexPath)
        proxy.getViewForHeader = self.viewForHeader
        proxy.getViewForFooter = self.viewForFooter
        proxy.getHeightForHeader = self.heightForHeader
        proxy.getHeightForFooter = self.heightForFooter
        return proxy
        }()
    
    public var delegate: UITableViewDelegate? {
        get {
            return dProxy.delegate
        }
        set {
            let t = newValue!
            dProxy.delegate = t
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
    
    func createCellBinding<CellType: UITableViewCell where CellType: BindableCellView>(cellType: CellType.Type)(viewModel: AnyObject, indexPath: NSIndexPath) -> UITableViewCell? {
        if let vm = viewModel as? CellType.ViewModelType {
            let cell = tableView.dequeueReusableCellWithIdentifier(CellType.CellIdentifier, forIndexPath: indexPath) as! CellType
            cell.viewModel = vm
            onWillBindCell?(cell, indexPath)
            cell.bindToViewModel()
            onCellBinded?(cell, indexPath)
            return cell
        }
        return nil
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
    
    public var onWillBindCell: CellAction?
    public var onCellBinded: CellAction?
    public var onCellsInserted: CellsChangedEvent?
    public var onCellsRemoved: CellsChangedEvent?
    public var onCellsReloaded: CellsChangedEvent?
}

@objc class UITableViewDataSourceProxy: NSObject, UITableViewDataSource {
    
    init(getCount: ((UITableView, Int) -> Int), getCell: ((UITableView, NSIndexPath) -> UITableViewCell)) {
        self.getCell = getCell
        self.getCount = getCount
    }
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return getSectionCount(tableView)
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCount(tableView, section)
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getCell(tableView, indexPath)
    }
    
    @objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getTitleForHeader(tableView, section)
    }
    
    @objc func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return getTitleForFooter(tableView, section)
    }
    
    var getSectionCount: (UITableView -> Int)!
    var getCount: ((UITableView, Int) -> Int)!
    var getCell: ((UITableView, NSIndexPath) -> UITableViewCell)!
    var getTitleForHeader: ((UITableView, Int) -> String?)!
    var getTitleForFooter: ((UITableView, Int) -> String?)!
}

@objc class UITableViewDelegateProxy: UITableViewDelegateForwarder {
    init(onSelect: (UITableView, NSIndexPath) -> ()) {
        self.onSelect = onSelect
        super.init()
    }
    
    // nil means "use default stub view of non empty area"
    @objc override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getViewForHeader(tableView, section)
    }
    
    @objc override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return getViewForFooter(tableView, section)
    }
    
    @objc override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return getHeightForHeader(tableView, section)
    }
    
    @objc override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return getHeightForFooter(tableView, section)
    }
    
    var onSelect:((UITableView, NSIndexPath) -> ())!
    var getViewForHeader: ((UITableView, Int) -> UIView?)!
    var getViewForFooter: ((UITableView, Int) -> UIView?)!
    var getHeightForHeader: ((UITableView, Int) -> CGFloat)!
    var getHeightForFooter: ((UITableView, Int) -> CGFloat)!
}