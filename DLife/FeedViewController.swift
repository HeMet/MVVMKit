//
//  SBViewController.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class FeedViewController : UITableViewController, SBViewForViewModel, UITableViewDelegate {
    static let sbInfo = (sbID: "Main", viewID: "FeedViewController")
    
    var viewModel : FeedViewModel!
    var adapter: TableViewArrayAdapter<DLEntry>!
    
    func bindToViewModel() {
        let tv = view as! UITableView
        tv.estimatedRowHeight = 150
        tv.rowHeight = UITableViewAutomaticDimension
        adapter = TableViewArrayAdapter(tableView: tv)
        adapter.registerCell(EntryCellView.self)
        adapter.onCellBinded = { cell, _ in
            if let ec = cell as? EntryCellView {
                ec.tableView = self.tableView
            }
        }
        adapter.onCellsInserted = { [unowned self] _, paths in
            var path = NSIndexPath(forRow: paths[0].row - 1, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        adapter.delegate = self
        adapter.setData(viewModel.entries)
        
        viewModel.loadEntries()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.showEntryAtIndex(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! EntryCellView).visible = true
        if indexPath.row == viewModel.entries.endIndex - 1 {
            self.viewModel.loadEntries()
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as! EntryCellView).visible = false
    }
}
