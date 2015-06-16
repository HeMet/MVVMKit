//
//  TableViewArrayAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import UIKit

public class TableViewArrayAdapter<T: AnyObject> {
    typealias CellBinding = (AnyObject, NSIndexPath) -> UITableViewCell?
    typealias CellsChangedEvent = (TableViewArrayAdapter<T>, [NSIndexPath]) -> ()
    
    let tag = "observable_array_tag"
    
    var data = ObservableArray<T>()
    let tableView: UITableView
    var cellBindings = [CellBinding]()
    lazy var dsProxy: UITableViewDataSourceProxy = { [unowned self] in
        UITableViewDataSourceProxy(getCount: self.numberOfRowsInSection, getCell: self.cellForRowAtIndexPath)
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
        data.unregisterChangeObserver(tag)
        data.unregisterInsertObserver(tag)
        data.unregisterRemoveObserver(tag)
        data.unregisterUpdatePhaseObserver(tag)
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
    
    public func setData(newData: [T]) {
        data = ObservableArray<T>(array: newData)
        
        data.registerChangeObserver(tag, observer: handleItemsChanged)
        data.registerInsertObserver(tag, observer: handleItemsInserted)
        data.registerRemoveObserver(tag, observer: handleItemsRemoved)
        data.registerUpdatePhaseObserver(tag, observer: handleUpdatePhase)
        
        tableView.reloadData()
    }
    
    var originOnItemsChanged, originOnItemsInserted, originOnItemsRemoved: ObservableArray<T>.RangeChangedCallback!
    
    public func setData(newData: ObservableArray<T>) {
        data.unregisterChangeObserver(tag)
        data.unregisterInsertObserver(tag)
        data.unregisterRemoveObserver(tag)
        data.unregisterUpdatePhaseObserver(tag)
        
        data = newData
        
        data.registerChangeObserver(tag, observer: handleItemsChanged)
        data.registerInsertObserver(tag, observer: handleItemsInserted)
        data.registerRemoveObserver(tag, observer: handleItemsRemoved)
        data.registerUpdatePhaseObserver(tag, observer: handleUpdatePhase)
        
        tableView.reloadData()
    }
    
    private func intercept<ArgsType>(origin: (ArgsType -> ())?, hook: ArgsType -> ()) -> ArgsType -> () {
        return { args in
            origin?(args)
            hook(args)
        }
    }
    
    func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        return data.count
    }
    
    func cellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel: AnyObject = data[indexPath.row]
        for bind in cellBindings {
            if let cell = bind(viewModel, indexPath) {
                onCellBinded?(cell, indexPath)
                return cell
            }
        }
        fatalError("Unknown View Model type.")
    }
    
    func didSelectRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) {
        
    }
    
    func handleUpdatePhase(sender: ObservableArray<T>, phase: UpdatePhase) {
        switch phase {
        case .Begin:
            tableView.beginUpdates()
        case .End:
            tableView.endUpdates()
        }
    }
    
    func handleItemsChanged(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        let paths = pathsOf(range)
        tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .Left)
        onCellsReloaded?(self, paths)
    }
    
    func handleItemsInserted(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        let paths = pathsOf(range)
        tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Right)
        onCellsInserted?(self, paths)
    }
    
    func handleItemsRemoved(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        let paths = pathsOf(range)
        tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Middle)
        onCellsRemoved?(self, paths)
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