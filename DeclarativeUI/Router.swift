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
    
    private var points = [String:ViewBuilder]()
    
    func route<ViewType: ViewForViewModel>(id: String, to: ViewType.Type) -> RoutePoint<ViewType> {
        let rp = RoutePoint<ViewType>()
        points[id] = rp
        return rp
    }
    
    func navigate<ViewModelType: AnyObject>(id: String, viewModel: ViewModelType) {
        let point = points[id]!
        
        let vc = point.buildView(viewModel)
        handleGroupView(id, view: vc)
        
        let from = UIApplication.sharedApplication().topViewController ?? UIViewController()
        
        point.t(from, vc, id)
    }
    
    func handleGroupView(id:String, view: UIViewController) {
        if let split = view as? UISplitViewController {
            handleSplitView(id, splitView: split)
        }
    }
    
    func handleSplitView(id: String, splitView: UISplitViewController) {
        let masterID = id + ".master"
        let detailID = id + ".detail"
        var views = [UIViewController]()
        if let masterPoint = points[masterID] {
            views.append(masterPoint.buildView(""))
        }
        if let detailPoint = points[detailID] {
            views.append(detailPoint.buildView(""))
        }
        splitView.viewControllers = views
    }
}

// Predefined transitions
struct Transitions {
    static let root: Router.Transition = { (from: UIViewController, to: UIViewController, id: String) in
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.rootViewController = to
        window?.makeKeyAndVisible()
    }
    
    static let show: Router.Transition = { (from: UIViewController, to: UIViewController, id: String) in
        from.showViewController(to, sender: from);
    }
    
    static let showDetail: Router.Transition = { (from: UIViewController, to: UIViewController, id: String) in
        from.showDetailViewController(to, sender: from);
    }
    
    static let showModal: Router.Transition = { (from: UIViewController, to: UIViewController, id: String) in
        from.presentViewController(to, animated: true, completion: nil)
    }
}

protocol ViewBuilder {
    func buildView(viewModel: AnyObject) -> UIViewController
    var t: Router.Transition! { get }
}

// it's seems imposible to define constraint as "class T and subclasses that support protocol P"
//1. can instantiate View model and bind it to ViewModel
//2. known that transition should be performed to move to this view
//3. optionally it can wrap View in common container views
class RoutePoint<VType where VType: ViewForViewModel> : ViewBuilder {
    typealias VMType = VType.ViewModelType
    typealias ViewFactory = (VMType) -> UIViewController
    
    var t: Router.Transition!
    private var createHierarchy: ViewFactory = { vm in
        return VType(viewModel: vm) as! UIViewController
    }
    
    func withFactory(factory: ViewFactory) -> RoutePoint {
        createHierarchy = factory
        return self
    }
    
    func withTransition(t: Router.Transition) -> RoutePoint {
        self.t = t
        return self
    }
    
    //factory method
    class func createView(viewModel: VMType) -> VType {
        return VType(viewModel: viewModel)
    }
    
    func buildView(viewModel: AnyObject) -> UIViewController {
        let typedVM = viewModel as! VMType
        return createHierarchy(typedVM)
    }
    
    func wrapInNavigationBar() -> RoutePoint {
        let ch = createHierarchy
        createHierarchy = { vm in
            return UINavigationController(rootViewController: ch(vm))
        }
        return self
    }
}