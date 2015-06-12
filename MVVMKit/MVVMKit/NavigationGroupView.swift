//
//  NavigationGroupView.swift
//  MVVMKit
//
//  Created by Евгений Губин on 11.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public class NavigationGroupView: UINavigationController {
    override public func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        if let vc = super.popViewControllerAnimated(animated) {
            disposeViewModelsOfViews([vc])
            return vc
        }
        return nil
    }

    override public func popToViewController(viewController: UIViewController, animated: Bool) -> [AnyObject]? {
        if let views = super.popToViewController(viewController, animated: animated) {
            disposeViewModelsOfViews(views as! [UIViewController])
            return views
        }
        return nil
    }

    override public func popToRootViewControllerAnimated(animated: Bool) -> [AnyObject]? {
        if let views = super.popToRootViewControllerAnimated(animated) {
            disposeViewModelsOfViews(views as! [UIViewController])
            return views
        }
        return nil
    }
    
    func disposeViewModelsOfViews(views: [UIViewController]) {
        for view in views {
            if let vm = VMTracker.getViewModel(view) as? ViewModel {
                vm.dispose()
            }
        }
    }
}
