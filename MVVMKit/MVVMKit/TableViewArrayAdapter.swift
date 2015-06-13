//
//  TableViewArrayAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import UIKit

@objc public class TableViewArrayAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    typealias CellBinding = (AnyObject, NSIndexPath) -> UITableViewCell?
    
    var data = ObservableArray<AnyObject>()
    let tableView: UITableView
    var cellBindings = [CellBinding]()
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        
        super.init()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
    
    public func setData(newData: [AnyObject]) {
        data.onItemChanged = nil;
        data.onItemInserted = nil;
        data.onItemRemoved = nil;
        
        data = ObservableArray<AnyObject>(array: newData)
        
        data.onItemChanged = handleItemChanged
        data.onItemInserted = handleItemInserted
        data.onItemRemoved = handleItemRemoved
        
        tableView.reloadData()
    }
    
    @objc public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel: AnyObject = data[indexPath.row]
        for bind in cellBindings {
            if let cell = bind(viewModel, indexPath) {
                return cell
            }
        }
        fatalError("Unknown View Model type.")
    }
    
    func handleItemChanged(sender: ObservableArray<AnyObject>, item: AnyObject, index: Int) {
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Left)
    }
    
    func handleItemInserted(sender: ObservableArray<AnyObject>, item: AnyObject, index: Int) {
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Right)
    }
    
    func handleItemRemoved(sender: ObservableArray<AnyObject>, item: AnyObject, index: Int) {
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Middle)
    }
}