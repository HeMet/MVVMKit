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
        adapter = TableViewArrayAdapter(tableView: view as! UITableView)
        adapter.registerCell(EntryCellView.self)
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
        if indexPath.row == viewModel.entries.endIndex - 1 {
            viewModel.loadEntries()
        }
    }
}
