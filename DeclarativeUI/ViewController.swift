//
//  ViewController.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 25.03.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ViewForViewModel {

    let viewModel : String
    
    var subviewHook : UIView!
    
    required init(viewModel: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        self.viewModel = ""
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        view = UIView() => {
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            $0.backgroundColor = UIColor.redColor()
            
            $0 => [
                self.subviewHook ~> UIView() => {
                    $0.backgroundColor = UIColor.greenColor()
                    $0.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
                }
            ]
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        router.navigate(self.viewModel, id: "next", viewModels: "empty")
    }
    
    func bindToViewModel() {
        
    }
    
    func bind(viewModel: String) {
        
    }
}

