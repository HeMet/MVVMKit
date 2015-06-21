//
//  TableViewBaseAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public class TableViewBaseAdapter<T: ObservableCollection> {
    typealias CellBinding = (AnyObject, NSIndexPath) -> UITableViewCell?
    typealias CellsChangedEvent = (TableViewBaseAdapter<T>, [NSIndexPath]) -> ()
    
    let tag = "observable_array_tag"
    
    var data: T = T(data: [])
    
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
    
    deinit {
        stopListeningForData()
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
    
    public func setData(newData: [T.ItemType]) {
        let data = T(data: newData)
        setData(data)
    }
    
    public func setData(newData: T) {
        stopListeningForData()
        data = newData
        beginListeningForData()
        
        tableView.reloadData()
    }
    
    func beginListeningForData() {
        data.onDidInsertRange.register(tag) {
            self.handleItemsInserted($0, items: $1.0, range: $1.1)
        }
        
        data.onDidRemoveRange.register(tag) {
            self.handleItemsRemoved($0, items: $1.0, range: $1.1)
        }
        
        data.onDidChangeRange.register(tag) {
            self.handleItemsChanged($0, items: $1.0, range: $1.1)
        }
        
        data.onBatchUpdate.register(tag, listener: handleUpdatePhase)
    }
    
    func stopListeningForData() {
        data.onDidInsertRange.unregister(tag)
        data.onDidRemoveRange.unregister(tag)
        data.onDidChangeRange.unregister(tag)
        data.onBatchUpdate.unregister(tag)
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
    
    func handleUpdatePhase(sender: T, phase: UpdatePhase) {
        switch phase {
        case .Begin:
            tableView.beginUpdates()
        case .End:
            tableView.endUpdates()
        }
    }
    
    func handleItemsChanged(sender: T, items: [T.ItemType], range: Range<Int>) {
        fatalError("Abstract method")    }
    
    func handleItemsInserted(sender: T, items: [T.ItemType], range: Range<Int>) {
        fatalError("Abstract method")
    }
    
    func handleItemsRemoved(sender: T, items: [T.ItemType], range: Range<Int>) {
        fatalError("Abstract method")
    }
    
    func pathsOf(itemIndexes: Range<Int>) -> [NSIndexPath] {
        return map(itemIndexes) {
            NSIndexPath(forRow: $0, inSection: 0)
        }
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