//
//  TableViewDictionaryAdapter.swift
//  MVVMKit
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public class TableViewDictionaryAdapter<K: Hashable, T>: TableViewBaseAdapter<ObservableOrderedMultiDictionary2<K, T>> {
    
    public override init(tableView: UITableView) {
        super.init(tableView: tableView)
    }
    
    override func numberOfRowsInSection(tableView: UITableView, section: Int) -> Int {
        return data.count
    }
    
    override func cellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
//        let viewModel: AnyObject = data[indexPath.row]
//        for bind in cellBindings {
//            if let cell = bind(viewModel, indexPath) {
//                onCellBinded?(cell, indexPath)
//                return cell
//            }
//        }
        fatalError("Unknown View Model type.")
    }

}