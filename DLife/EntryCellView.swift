//
//  EntryCellView.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit
import WebImage

class EntryCellView: UITableViewCell, ViewForViewModel, BindableCellView
{
    static let CellIdentifier = "EntryCellView"
    
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblRatingValue: UILabel!
    @IBOutlet weak var lblCommentCount: UILabel!
    
    var viewModel: DLEntry!
    
    func bindToViewModel() {
        imgPicture.sd_setImageWithURL(NSURL(string: viewModel.previewURL))
        lblDescription.text = viewModel.description
        lblRatingValue.text = "\(viewModel.votes)"
    }
}
