//
//  EntryViewController.swift
//  DLife
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class EntryViewController: UIViewController, SBViewForViewModel {
    static let sbInfo = (sbID: "Main", viewID: "EntryViewController")
    
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblRatingValue: UILabel!
    
    var viewModel: DLEntry!
    
    func bindToViewModel() {
        imgPicture.sd_setImageWithURL(NSURL(string: viewModel.gifURL))
        lblDescription.text = viewModel.description
        lblRatingValue.text = "\(viewModel.votes)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
}
