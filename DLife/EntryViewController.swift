//
//  EntryViewController2.swift
//  DLife
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class EntryViewController: UITableViewController, SBViewForViewModel {
    static let sbInfo = (sbID: "Main", viewID: "EntryViewController2")
    
    var viewModel: EntryViewModel!
    var adapter: TableViewArrayAdapter<AnyObject>!
    
    func bindToViewModel() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerNib(UINib(nibName: "EntryCellView", bundle: nil), forCellReuseIdentifier: EntryCellView.CellIdentifier)
        
        adapter = TableViewArrayAdapter(tableView: tableView)
        adapter.registerCell(EntryCellView.self)
        adapter.registerCell(CommentCellView.self)
        
        adapter.setData(viewModel.data)
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
}