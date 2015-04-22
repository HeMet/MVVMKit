//
//  BuiltInGroupViews.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 12.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

 extension UISplitViewController : GroupViewForViewModels {
    public func attachChildViews(children: OrderedDictionary<String, UIViewController>) {
        self.viewControllers = [children["master"]!, children["detail"]!]
    }
}

extension UITabBarController : GroupViewForViewModels {    
    public func attachChildViews(children: OrderedDictionary<String, UIViewController>) {
        var childViews = [UIViewController]()
        for e in children {
            childViews.append(e.1)
        }
        self.viewControllers = childViews
    }
}