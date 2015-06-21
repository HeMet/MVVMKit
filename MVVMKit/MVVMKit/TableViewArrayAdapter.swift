//
//  TableViewArrayAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import UIKit

public class TableViewArrayAdapter<T: AnyObject> : TableViewSinglePartAdapter<ObservableArray<T>> {
    typealias CellBinding = (AnyObject, NSIndexPath) -> UITableViewCell?
    typealias CellsChangedEvent = (TableViewArrayAdapter<T>, [NSIndexPath]) -> ()
    
    //public init(tableView: UITableView, array: ObservableArray<T>)
    
    //public init(tableView: UITableView, sourceSignal: Signal<[T], NoError>)
    
    public override init(tableView: UITableView) {
        super.init(tableView: tableView)
    }
    
    override func numberOfSections(tableView: UITableView) -> Int {
        return 1
    }
    
    override func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        return data.count
    }
    
    override func viewModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return data[indexPath.row]
    }
    
    override func handleItemsChanged(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        let paths = pathsOf(range)
        tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .Left)
        onCellsReloaded?(self, paths)
    }
    
    override func handleItemsInserted(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        let paths = pathsOf(range)
        tableView.insertRowsAtIndexPaths(paths, withRowAnimation: .Right)
        onCellsInserted?(self, paths)
    }
    
    override func handleItemsRemoved(sender: ObservableArray<T>, items: [T], range: Range<Int>) {
        let paths = pathsOf(range)
        tableView.deleteRowsAtIndexPaths(paths, withRowAnimation: .Middle)
        onCellsRemoved?(self, paths)
    }
}