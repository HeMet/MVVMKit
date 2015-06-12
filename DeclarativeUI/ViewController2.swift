//
//  ViewController2.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 13.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class ViewController2: UIViewController, ViewForViewModel {
    
    var viewModel : SimpleViewModel!
    
    var subviewHook : UILabel!
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.viewModel = nil
        super.init(coder: aDecoder)
    }
    
    deinit {
        println("deinit2 \(viewModel)")
        viewModel.dispose()
    }
    
    override func loadView() {
        view = UIView() => {
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            $0.backgroundColor = UIColor.yellowColor()
            
            $0 => [
                self.subviewHook ~> UILabel() => {
                    $0.backgroundColor = UIColor.greenColor()
                    $0.frame = CGRect(x: 5, y: 5, width: 60, height: 30)
                    $0.text = self.viewModel.data
                }
            ]
        }
    }
        
    func bindToViewModel() {
        self.title = viewModel.data
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        println("parentVC2: \(parent)")
        super.didMoveToParentViewController(parent)
    }
}
