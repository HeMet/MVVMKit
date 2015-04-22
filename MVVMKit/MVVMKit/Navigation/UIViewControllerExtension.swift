//
//  UIViewControllerExtension.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 03.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

extension UIViewController {
    var router: Router {
        return (UIApplication.sharedApplication().delegate! as! UIMVVMApplication).router
    }
}
