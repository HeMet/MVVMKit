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
    
    var viewModel: DLEntry!
    
    var tableView: UITableView?
    var visible: Bool = false

    var done = false
    
    func bindToViewModel() {
        
        let ph = placeholderImage(viewModel.imgSize.0, viewModel.imgSize.1)
        imgPicture.sd_setImageWithURL(NSURL(string: viewModel.previewURL), placeholderImage: ph)
        lblDescription.text = viewModel.description
        lblRatingValue.text = "\(viewModel.votes)"
        
        if (!done) {
            let tr = UITapGestureRecognizer(target: self, action: Selector("handlePictureTap:"))
            imgPicture.addGestureRecognizer(tr)
            imgPicture.userInteractionEnabled = true
            
            done = true
        }
    }
    
    func handlePictureTap(recognizer: UITapGestureRecognizer) {
        imgPicture.sd_setImageWithURL(NSURL(string: viewModel.gifURL), placeholderImage: imgPicture.image!)
    }
    
    func sendSizeChanged() {
        if visible {
            // tell tableview to resize cell
            if let ip = tableView?.indexPathForCell(self) {
                tableView!.reloadRowsAtIndexPaths([ip], withRowAnimation: .Automatic)
            }
        }
    }
    
    func placeholderImage(width: Float, _ height: Float) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: CGFloat(width), height: CGFloat(height)))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension SDImageCacheType: Printable {
    public var description: String {
        switch (self) {
        case .None: return "None"
        case .Disk: return "Disk"
        case .Memory: return "Memory"
        }
    }
}