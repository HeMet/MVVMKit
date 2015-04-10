//
//  SplitView.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 10.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

class SplitView: UISplitViewController, ViewForViewModel {
    var viewModel: String
    
    required init(viewModel: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        self.viewModel = ""
        super.init(coder: aDecoder)
    }
    
    func bindToViewModel() {
        
    }
}
