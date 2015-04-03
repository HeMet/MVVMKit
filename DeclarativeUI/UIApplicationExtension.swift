//
//  UIApplicationExtension.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 03.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

extension UIApplication {
    var topViewController : UIViewController? {
        return topViewControllerWithRootViewController(UIApplication.sharedApplication().keyWindow?.rootViewController);
    }
    
    // todo: popovers
    func topViewControllerWithRootViewController(rootViewController : UIViewController?) -> UIViewController? {
        if let tabBarController = rootViewController as? UITabBarController {
            return topViewControllerWithRootViewController(tabBarController.selectedViewController)
        } else if let navigationController = rootViewController as? UINavigationController {
            return topViewControllerWithRootViewController(navigationController.visibleViewController)
        } else if let presentedVC = rootViewController?.presentedViewController {
            return topViewControllerWithRootViewController(presentedVC)
        } else {
            return rootViewController;
        }
    }
}
