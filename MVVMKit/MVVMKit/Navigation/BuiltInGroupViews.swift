//
//  BuiltInGroupViews.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 12.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public class TabBarView : GroupView {
    public static func assemble(views: [UIViewController]) -> UITabBarController {
        let tb = UITabBarController()
        tb.viewControllers = views
        return tb
    }
}

public class SplitView : GroupView {
    public static func assemble(views: [UIViewController]) -> UISplitViewController {
        let splitV = UISplitViewController()
        splitV.viewControllers = views
        return splitV
    }
}
