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
    
    var data = ObservableArray<T>()
    let tableView: UITableView
    var cellBindings = [CellBinding]()
    lazy var dsProxy: UITableViewDataSourceProxy = { [unowned self] in
        UITableViewDataSourceProxy(getCount: self.numberOfRowsInSection, getCell: self.cellForRowAtIndexPath)
    }()
    lazy var dProxy: UITableViewDelegateProxy = { [unowned self] in
        UITableViewDelegateProxy(onSelect: self.didSelectRowAtIndexPath)
    }()
    
    var areDelegatesAreSetted = false
    
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
    
    public func setData(newData: [T]) {
        data.onItemsChanged = nil;
        data.onItemsInserted = nil;
        data.onItemsRemoved = nil;
        
        data = ObservableArray<T>(array: newData)
        
        data.onItemsChanged = handleItemsChanged
        data.onItemsInserted = handleItemsInserted
        data.onItemsRemoved = handleItemsRemoved
        
        tableView.reloadData()
    }
    
    var originOnItemsChanged, originOnItemsInserted, originOnItemsRemoved: ObservableArray<T>.RangeChangedCallback!
    
    public func setData(newData: ObservableArray<T>) {
        
        data.onItemsChanged = originOnItemsChanged
        data.onItemsInserted = originOnItemsChanged
        data.onItemsRemoved = originOnItemsRemoved
        
        originOnItemsChanged = newData.onItemsChanged
        originOnItemsInserted = newData.onItemsInserted
        originOnItemsRemoved = newData.onItemsRemoved
        
        data = newData
        
        data.onItemsChanged = intercept(data.onItemsChanged, hook: handleItemsChanged)
        data.onItemsInserted = intercept(data.onItemsInserted, hook: handleItemsInserted)
        data.onItemsRemoved = intercept(data.onItemsRemoved, hook: handleItemsRemoved)
        
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
                return cell
            }
        }
        fatalError("Unknown View Model type.")
    }
    
    func didSelectRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) {
        
    }
    
    func handleItemsChanged(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        
        
        tableView.reloadRowsAtIndexPaths(pathsOf(range), withRowAnimation: .Left)
    }
    
    func handleItemsInserted(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        tableView.insertRowsAtIndexPaths(pathsOf(range), withRowAnimation: .Right)
    }
    
    func handleItemsRemoved(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        tableView.deleteRowsAtIndexPaths(pathsOf(range), withRowAnimation: .Middle)
    }
    
    func pathsOf(itemIndexes: Range<Int>) -> [NSIndexPath] {
        return map(itemIndexes) {
            NSIndexPath(forRow: $0, inSection: 0)
        }
    }
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