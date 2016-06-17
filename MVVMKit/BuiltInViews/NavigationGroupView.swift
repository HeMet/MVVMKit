//
//  NavigationGroupView.swift
//  MVVMKit
//
//  Created by Евгений Губин on 11.06.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

public class NavigationGroupView: UINavigationController {
    override public func popViewController(animated: Bool) -> UIViewController? {
        if let vc = super.popViewController(animated: animated) {
            disposeViewModelsOfViews([vc])
            return vc
        }
        return nil
    }

    override public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let views = super.popToViewController(viewController, animated: animated) {
            disposeViewModelsOfViews(views )
            return views
        }
        return nil
    }

    override public func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if let views = super.popToRootViewController(animated: animated) {
            disposeViewModelsOfViews(views )
            return views
        }
        return nil
    }
    
    func disposeViewModelsOfViews(_ views: [UIViewController]) {
        for view in views {
            if let vm = VMTracker.sharedInstance.getViewModelForView(view)?.value as? DisposableViewModel {
                vm.dispose()
            }
        }
    }
}
