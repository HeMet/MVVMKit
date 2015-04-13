//
//  BuiltInGroupViews.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 12.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

extension UISplitViewController : GroupViewForViewModels {
    func bindToViewModels(viewModels: [AnyObject], childFactory: ChildViewFactory) {
        assert(viewModels.count == 2, "SplitView must contains two child views.")
        
        let masterView = childFactory(childId: "master", childVM: viewModels[0])
        let detailView = childFactory(childId: "detail", childVM: viewModels[1])
        
        self.viewControllers = [masterView, detailView]
    }
}