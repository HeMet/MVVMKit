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
    var adapter: TableViewMultiDataAdapter!
    
    var htmlTexts: [NSAttributedString?] = []
    var commentsProxy: ObservableArray<DLComment> = []
    
    func bindToViewModel() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 20
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        tableView.registerNib(UINib(nibName: "EntryCellView", bundle: nil), forCellReuseIdentifier: EntryCellView.CellIdentifier)
        
        adapter = TableViewMultiDataAdapter(tableView: tableView)
        adapter.registerCell(EntryCellView.self)
        adapter.registerCell(CommentCellView.self)
        
        adapter.delegate = self
        adapter.onWillBindCell = setCommentTextForCell
        
        commentsProxy = ObservableArray(observableArray: viewModel.comments)
        
        adapter.beginUpdate()
        adapter.addData(viewModel.currentEntry)
        adapter.addData(commentsProxy)
        adapter.setTitle("Комментарии:", forSectionHeader: 1)
        adapter.endUpdate()
        
        viewModel.onEntryChanged = {
            self.adapter.changeData(self.viewModel.currentEntry, forSection: 0)
            self.navigationItem.title = "Entry\(self.viewModel.currentEntry.id)"
        }
        
        viewModel.comments.onBatchUpdate.register(cbTag, listener: parseCommentsTextAndUpdate)
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
    
    func setCommentTextForCell(cell: UITableViewCell, path: NSIndexPath) {
        if let commentCell = cell as? CommentCellView {
            commentCell.tvMessage.attributedText = self.htmlTexts[path.row]
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