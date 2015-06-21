//
//  TableViewArrayAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import UIKit

public class TableViewArrayAdapter<T: AnyObject> : TableViewBaseAdapter<ObservableArray<T>> {
    typealias CellBinding = (AnyObject, NSIndexPath) -> UITableViewCell?
    typealias CellsChangedEvent = (TableViewArrayAdapter<T>, [NSIndexPath]) -> ()
    
    //public init(tableView: UITableView, array: ObservableArray<T>)
    
    //public init(tableView: UITableView, sourceSignal: Signal<[T], NoError>)
    
    public override init(tableView: UITableView) {
        super.init(tableView: tableView)
    }
    
    override func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        return data.count
    }
    
    override func cellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel: AnyObject = data[indexPath.row]
        for bind in cellBindings {
            if let cell = bind(viewModel, indexPath) {
                onCellBinded?(cell, indexPath)
                return cell
            }
        }
        fatalError("Unknown View Model type.")
    }
}