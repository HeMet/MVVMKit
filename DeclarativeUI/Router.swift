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
    
    private var points = [String:ViewBuilder]()
    
    private var knownVM = [VMEntry]()
    
    func route<ViewType: ViewForViewModel>(id: String, to: ViewType.Type) -> RoutePoint<ViewType, ViewType.ViewModelType> {
        let rp = RoutePointWithVM<ViewType>()
        points[id] = rp
        return rp
    }
    
    func route<ViewType: UIViewController>(id: String, to: ViewType.Type) -> RoutePoint<ViewType, AnyObject> {
        let rp = ModelessRoutePoint<ViewType>()
        points[id] = rp
        return rp
    }
    
    func navigate<ViewModelType: AnyObject>(sender: AnyObject, id: String, viewModels: ViewModelType...) {
        cleanDeadVM()
        
        let point = points[id]!
        
        let to : UIViewController
        if (point is GroupViewRoutePoint) {
            to = point.buildView("[placeholder]")
            handleGroupView(id, view: to as! GroupViewForViewModels, viewModels: viewModels)
        } else {
            assert(viewModels.count == 1, "Too many View Models. This View can be bound to one View Model only.")
            to = point.buildView(viewModels.first!)
            knownVM.append(VMEntry(vm: viewModels.first!, view: to))
        }
        
        let from = getFromView(sender) ?? UIViewController()
        point.t(from, to, id)
    }
    
    func getFromView(sender: AnyObject) -> UIViewController? {
        return knownVM.filter({ $0.vm === sender }).first?.view
    }
    
    func handleGroupView(id:String, view: GroupViewForViewModels, viewModels: [AnyObject]) {        
        view.bindToViewModels(viewModels) { (childID: String, childVM: AnyObject) -> UIViewController in
            let point = self.points["\(id).\(childID)"]!
            assert(point.canBindViewModel(childVM), "Wrong View Model for child View.")
            let childView = point.buildView(childVM)
            self.knownVM.append(VMEntry(vm: childVM, view: childView))
            
            return childView
        }
    }
    
    func cleanDeadVM() {
        var aliveVM = [VMEntry]()
        for entry in knownVM {
            if entry.vm != nil && entry.view != nil {
                aliveVM.append(entry)
            }
        }
        
        if (knownVM.count != aliveVM.count) {
            knownVM = aliveVM
        }
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