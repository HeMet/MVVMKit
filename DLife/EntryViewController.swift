//
//  EntryViewController2.swift
//  DLife
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class EntryViewController: UITableViewController, SBViewForViewModel, UITableViewDelegate {
    static let sbInfo = (sbID: "Main", viewID: "EntryViewController2")
    
    var viewModel: EntryViewModel!
    var adapter: TableViewMultiDataAdapter!
    
    func bindToViewModel() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerNib(UINib(nibName: "EntryCellView", bundle: nil), forCellReuseIdentifier: EntryCellView.CellIdentifier)
        
        adapter = TableViewMultiDataAdapter(tableView: tableView)
        adapter.registerCell(EntryCellView.self)
        adapter.registerCell(CommentCellView.self)
        
        adapter.addData(viewModel.currentEntry)
        adapter.addData(viewModel.comments)
        
        viewModel.onEntryChanged = {
            self.adapter.changeData(self.viewModel.currentEntry, forSection: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
    
    @IBAction func nextRandomPostTapped(sender: AnyObject) {
        viewModel.nextRandomPost()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadComments()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let ecv = cell as? EntryCellView {
            ecv.entryView.loadGif()
        }
    }
}