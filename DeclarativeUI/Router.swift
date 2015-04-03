//
//  Router.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 02.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

class Router : NSObject {
    // from, to, what
    typealias Transition = (UIViewController, UIViewController, String) -> ()
    
    private var points = [String:RoutePoint]()
    
    func route(id: String) -> RoutePoint {
        let rp = RoutePoint()
        points[id] = rp
        return rp;
    }
    
    func navigate(id: String, viewModel: AnyObject) {
        if let point = points[id] {
            let vc = point._toFactory(viewModel)
            let from = UIApplication.sharedApplication().topViewController ?? UIViewController()
            point._transition(from, vc, id)
        }
    }
}

// Predefined transitions
struct Transitions {
    static var push: Router.Transition = { (from: UIViewController, to: UIViewController, id: String) in
        if let nav = from.navigationController {
            nav.pushViewController(to, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: to)
            from.presentViewController(nav, animated: true, completion: nil)
        }
    }

    static var root: Router.Transition = { (from: UIViewController, to: UIViewController, id: String) in
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.rootViewController = to
        window?.makeKeyAndVisible()
    }
    
    static var show: Router.Transition = { (from: UIViewController, to: UIViewController, id: String) in
        from.showViewController(to, sender: from);
    }
    
    static var showModal: Router.Transition = { (from: UIViewController, to: UIViewController, id: String) in
        from.presentViewController(to, animated: true, completion: nil)
    }
}

// short version for Storyboard?
class RoutePoint {
    typealias ViewFactory = (AnyObject) -> UIViewController
    
    var _toFactory: ViewFactory!
    var _transition: Router.Transition!
    
    func toView(factory: ViewFactory) -> RoutePoint {
        _toFactory = factory
        return self
    }
    
    func withTransition(t: Router.Transition) -> RoutePoint {
        _transition = t
        return self
    }
}