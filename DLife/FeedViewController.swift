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
    var adapter: TableViewAdapter!
    
    func bindToViewModel() {
        let tv = view as! UITableView
        tv.estimatedRowHeight = 150
        tv.rowHeight = UITableViewAutomaticDimension
        
        adapter = TableViewAdapter(tableView: tv)
        adapter.cells.register(EntryCellView.self)
        
        adapter.onCellsInserted = { [unowned self] _, paths in
            let row = max(paths[0].row - 1, 0)
            self.adapter.performAfterUpdate {
                if (row > 0) {
                    var path = NSIndexPath(forRow: row, inSection: 0)
                    $0.scrollToRowAtIndexPath(path, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                } else {
                    $0.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                }
            }
        }
        
        adapter.delegate = self
        adapter.setData(viewModel.entries, forSectionAtIndex: 0)
        
        viewModel.loadEntries()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.showEntryAtIndex(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == viewModel.entries.endIndex - 1 {
            self.viewModel.loadEntries()
        }
    }
    
    @IBAction func handleCategoryChanged(sender: AnyObject) {
        let sc = sender as! UISegmentedControl
        switch sc.selectedSegmentIndex {
        case 0:
            viewModel.category = .Latest
        case 1:
            viewModel.category = .Top
        case 2:
            viewModel.category = .Hot
        default:
            break
        }
    }
}
