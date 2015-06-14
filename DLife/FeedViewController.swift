//
//  SBViewController.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class FeedViewController : UITableViewController, SBViewForViewModel {
    static let sbInfo = (sbID: "Main", viewID: "FeedViewController")
    
    var viewModel : FeedViewModel!
    var adapter: TableViewArrayAdapter<DLEntry>!
    
    func bindToViewModel() {
        adapter = TableViewArrayAdapter(tableView: view as! UITableView)
        adapter.registerCell(EntryCellView.self)
        adapter.setData(viewModel.entries)
        adapter.onItemSelectedAtIndex = { [unowned self] in
            self.viewModel.showEntryAtIndex($0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.loadEntries()
    }
}
