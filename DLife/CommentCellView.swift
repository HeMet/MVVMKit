//
//  CommentCellView.swift
//  DLife
//
//  Created by Евгений Губин on 21.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class CommentCellView: UITableViewCell, ViewForViewModel, BindableCellView {
    static var CellIdentifier = "CommentCellView"
    
    var viewModel: DLComment!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var lcTextHeight: NSLayoutConstraint!
    
    func bindToViewModel() {
        lblHeader.text = "@rating: \(viewModel.voteCount) @author: \(viewModel.authorName) @date: \(viewModel.date)"
        
        // tvMessage.attributesText setted up by table view
        
        lcTextHeight.constant = tvMessage.sizeThatFits(tvMessage.frame.size).height
    }
}
