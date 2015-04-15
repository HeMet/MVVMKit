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
    
    private class VMEntry {
        weak var vm: AnyObject?
        weak var view: UIViewController?
        
        init (vm: AnyObject, view: UIViewController) {
            self.vm = vm
            self.view = view
        }
    }
    
    private var points = OrderedDictionary<String, ViewBuilder>()
    
    private var knownVM = [VMEntry]()
    
    func route<ViewType: ViewForViewModel>(id: String, to: ViewType.Type) -> RoutePoint<ViewType, ViewType.ViewModelType> {
        let rp = RoutePointWithVM<ViewType>()
        points[id] = rp
        return rp
    }
    
    func route<ViewType: UIViewController where ViewType: GroupViewForViewModels>(id: String, to: ViewType.Type) -> RoutePoint<ViewType, AnyObject> {
        let rp = ModelessRoutePoint<ViewType>()
        points[id] = rp
        return rp
    }
    
    func navigate(sender: AnyObject, id: String, viewModel: AnyObject) {
        internalNavigate(sender, viewModels: [id: viewModel])
    }
    
    func navigate(sender: AnyObject, id: String, viewModels: Dictionary<String, AnyObject>) {
        var vms = OrderedDictionary<String, AnyObject>()
        vms[id] = "[placeholder]"
        for e in viewModels {
            vms[id + "." + e.0] = e.1
        }
        internalNavigate(sender, viewModels: vms)
    }
    
    func internalNavigate(sender: AnyObject, viewModels: OrderedDictionary<String, AnyObject>) {
        cleanDeadVM()
        
        var vms = viewModels
        vms.keys.sort { (a, b) -> Bool in
            return self.getIDWeight(a) < self.getIDWeight(b)
        }
        
        let binding = vms.removeAtIndex(0)
        let point = getBindingWithID(binding.0)
        let to = bindViewModel(binding.1, binding: point)
        bindViewModels(to, viewModels: vms)
        
        //todo: add check when from is needed or not
        let from = getFromView(sender) ?? UIViewController()
        point.t(from, to, binding.0)
    }
    
    func bindViewModels(parentView: UIViewController, viewModels: OrderedDictionary<String, AnyObject>) {
        var views = OrderedDictionary<String, UIViewController>()
        for e in viewModels {
            let point = getBindingWithID(e.0)
            let (pid, cid) = devideID(e.0)
            
            let view = bindViewModel(e.1, binding: point)
            if view is GroupViewForViewModels {
                let children = getChildren(pid, viewModels: viewModels)
                bindViewModels(view, viewModels: children)
            } else {
                views[cid] = view
                
            }
        }
        
        if (views.count > 0) {
            let groupView = parentView as! GroupViewForViewModels
            groupView.attachChildViews(views)
        }
    }
    
    func bindViewModel(viewModel: AnyObject, binding: ViewBuilder) -> UIViewController {
        assert(binding.canBindViewModel(viewModel), "Wrong View Model for child View.")
        
        let result = binding.buildView(viewModel)
        if (!(result is GroupViewForViewModels)) {
            knownVM.append(VMEntry(vm: viewModel, view: result))
        }
        
        return result
    }
    
    func getChildren(parentID: String, viewModels: OrderedDictionary<String, AnyObject>) -> OrderedDictionary<String, AnyObject> {
        var result = OrderedDictionary<String, AnyObject>()
        for e in viewModels {
            let (pid, cid) = devideID(e.0)
            if pid == parentID {
                result[cid] = e.1
            }
        }
        return result
    }
    
    func getBindingWithID(id: String) -> ViewBuilder {
        assert(points[id] != nil, "Unknown binding: \(id)")
        return points[id]!
    }
    
    func devideID(id: String) -> (String, String) {
        var components = id.componentsSeparatedByString(".")
        let parentID = components.removeAtIndex(0)
        let childID = ".".join(components)
        
        return (parentID, childID)
    }
    
    func getIDWeight(id: String) -> Int {
        var components = id.componentsSeparatedByString(".")
        return components.count - 1
    }
    
    func getFromView(sender: AnyObject) -> UIViewController? {
        return knownVM.filter({ $0.vm === sender }).first?.view
    }
    
    func cleanDeadVM() {
        let alive = knownVM.filter {
            $0.vm != nil && $0.view != nil
        }
        knownVM = alive
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
    func canBindViewModel(viewModel: AnyObject) -> Bool
    func buildView(viewModel: AnyObject) -> UIViewController
    var t: Router.Transition! { get }
}

protocol GroupViewRoutePoint { }

//1. can instantiate View model and bind it to ViewModel
//2. known that transition should be performed to move to this view
//3. optionally it can wrap View in common container views
class RoutePoint<VType, VMType> : ViewBuilder {
    typealias ViewFactory = (VMType) -> UIViewController
    
    var t: Router.Transition!
    
    // abstract
    var createHierarchy: ViewFactory!
    
    func canBindViewModel(viewModel: AnyObject) -> Bool {
        return false
    }
    
    func withFactory(factory: ViewFactory) -> RoutePoint {
        createHierarchy = factory
        return self
    }
    
    func withTransition(t: Router.Transition) -> RoutePoint {
        self.t = t
        return self
    }
    
    //ABSTRACT factory method
    class func createView(viewModel: VMType) -> VType! {
        return nil
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

class ModelessRoutePoint<VType: UIViewController>: RoutePoint<VType, AnyObject>, GroupViewRoutePoint {
    override init() {
        super.init()
        createHierarchy = { vm in
            return VType()
        }
    }
    
    override func canBindViewModel(viewModel: AnyObject) -> Bool {
        return true
    }
    
    override class func createView(viewModel: AnyObject) -> VType! {
        return VType()
    }
}

// it's seems imposible to define constraint as "class T and subclasses that support protocol P"
class RoutePointWithVM<VType where VType: ViewForViewModel>: RoutePoint<VType, VType.ViewModelType> {
    typealias VMType = VType.ViewModelType
    
    override init() {
        super.init()
        createHierarchy = { vm in
            return VType(viewModel: vm) as! UIViewController
        }
    }
    
    override func canBindViewModel(viewModel: AnyObject) -> Bool {
        return viewModel is VType.ViewModelType
    }
    
    override class func createView(viewModel: VMType) -> VType! {
        return VType(viewModel: viewModel)
    }
}