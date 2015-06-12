//
//  SBViewController.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class SBViewController : UIViewController, SBViewForViewModel {
    static let sbID = "Main"
    static let viewID = "SBViewController"
    
    var viewModel : SimpleViewModel!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    func bindToViewModel() {
        lblMessage.text = viewModel.data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
}
