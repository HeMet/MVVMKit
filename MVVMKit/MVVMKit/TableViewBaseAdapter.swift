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
    
    let tag = "observable_array_tag"
    
    let tableView: UITableView
    var cellBindings = [CellBinding]()
    lazy var dsProxy: UITableViewDataSourceProxy = { [unowned self] in
        var proxy = UITableViewDataSourceProxy(getCount: self.numberOfRowsInSection, getCell: self.cellForRowAtIndexPath)
        proxy.getSectionCount = self.numberOfSections
        return proxy
        }()
    lazy var dProxy: UITableViewDelegateProxy = { [unowned self] in
        UITableViewDelegateProxy(onSelect: self.didSelectRowAtIndexPath)
        }()
    
    public var delegate: UITableViewDelegate? {
        get {
            return dProxy.delegate
        }
        set {
            let t = newValue!
            dProxy.delegate = t
            self.tableView.delegate = dProxy
        }
    }
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        self.tableView.dataSource = dsProxy
    }
    
    //public init(tableView: UITableView, array: ObservableArray<T>)
    
    //public init(tableView: UITableView, sourceSignal: Signal<[T], NoError>)
    
    public func registerCell<CellType: UITableViewCell where CellType: BindableCellView, CellType: ViewForViewModel>(cellType: CellType.Type) {
        let binding = createCellBinding(cellType)
        cellBindings.append(binding)
    }
    
    func createCellBinding<CellType: UITableViewCell where CellType: BindableCellView>(cellType: CellType.Type)(viewModel: AnyObject, indexPath: NSIndexPath) -> UITableViewCell? {
        if let vm = viewModel as? CellType.ViewModelType {
            let cell = tableView.dequeueReusableCellWithIdentifier(CellType.CellIdentifier, forIndexPath: indexPath) as! CellType
            cell.viewModel = vm
            cell.bindToViewModel()
            return cell
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
                onCellBinded?(cell, indexPath)
                return cell
            }
        }
        fatalError("Unknown View Model type.")
    }
    
    func viewModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        fatalError("Abstract method")
    }
    
    func didSelectRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) {
        
    }
    
    public var onCellBinded: ((UITableViewCell, NSIndexPath) -> ())?
    public var onCellsInserted: CellsChangedEvent?
    public var onCellsRemoved: CellsChangedEvent?
    public var onCellsReloaded: CellsChangedEvent?
}

@objc class UITableViewDataSourceProxy: NSObject, UITableViewDataSource {
    
    init(getCount: ((UITableView, Int) -> Int), getCell: ((UITableView, NSIndexPath) -> UITableViewCell)) {
        self.getCell = getCell
        self.getCount = getCount
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCount(tableView, section)
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getCell(tableView, indexPath)
    }
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return getSectionCount(tableView)
    }
    
    var getSectionCount: (UITableView -> Int)!
    var getCount: ((UITableView, Int) -> Int)!
    var getCell: ((UITableView, NSIndexPath) -> UITableViewCell)!
}

@objc class UITableViewDelegateProxy: UITableViewDelegateForwarder {
    init(onSelect: (UITableView, NSIndexPath) -> ()) {
        self.onSelect = onSelect
        super.init()
    }
    
    var onSelect:((UITableView, NSIndexPath) -> ())!
}