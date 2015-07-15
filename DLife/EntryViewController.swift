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
    
    let cbTag = "EntryViewController"
    
    var viewModel: EntryViewModel!
    var adapter: TableViewAdapter!
    
    var htmlTexts: [NSAttributedString?] = []
    var commentsProxy: ObservableArray<DLComment> = []
    
    func bindToViewModel() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 20
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        adapter = TableViewAdapter(tableView: tableView)
        adapter.delegate = self
        
        adapter.cells.register(EntryCellView.self)
        adapter.cells.register(CommentCellView.self)
        adapter.cells.onWillBind = unowned(self, EntryViewController.handleWillBindCell)
        adapter.cells.onDidBind = { cell, path in
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
        }
        
        commentsProxy = ObservableArray(observableArray: viewModel.comments)
        
        adapter.beginUpdate()
        adapter.setData(viewModel.currentEntry, forSectionAtIndex: 0)
        adapter.setData(commentsProxy, forSectionAtIndex: 1)
        adapter.setTitle("Комментарии:", forSection: .Header, atIndex: 1)
        adapter.endUpdate()
        
        viewModel.onEntryChanged = { [unowned self] in
            self.adapter.setData(self.viewModel.currentEntry, forSectionAtIndex: 0)
            self.navigationItem.title = "Entry\(self.viewModel.currentEntry.id)"
        }
        
        viewModel.comments.onBatchUpdate.register(cbTag, listener: unowned(self, EntryViewController.parseCommentsTextAndUpdate))
        navigationItem.title = "Entry\(viewModel.currentEntry.id)"
    }
    
    func parseCommentsTextAndUpdate(comments: ObservableArray<DLComment>, phase: UpdatePhase) {
        switch phase {
        case .Begin:
            self.adapter.beginUpdate()
            self.commentsProxy.removeAll(false)
        case .End:
            let copy = ObservableArray(observableArray: comments)
            backgroundTask {
                var htmls = map(copy) { parseCommentText($0.text) }
                uiTask {
                    self.htmlTexts = htmls
                    self.commentsProxy.replaceAll(comments)
                    self.adapter.endUpdate()
                }
            }
        }
    }
    
    func handleWillBindCell(cell: UITableViewCell, path: NSIndexPath) {
        switch cell {
        case let commentCell as CommentCellView:
            commentCell.tvMessage.attributedText = self.htmlTexts[path.row]
        case let entryCell as EntryCellView:
            entryCell.entryView.instantGifLoading = true
        default:
            break
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
    
    deinit {
        println("dispose EVC")
    }
}