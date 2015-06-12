//
//  AltRouting.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 07.05.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public typealias Transition = (from: UIViewController, to: UIViewController) -> ()

infix operator *> {
    associativity left
    precedence 95
}

/// Pipe operator. It connects all steps in stream-like form.
public func *> <T, R>(value: T, f: T -> R) -> R {
    return f(value)
}

// Creation

prefix operator ! {}

/// Factory operator
///
/// For given ViewForViewModel type it returns factory function which takes View Model and returns View binded to it.
public prefix func ! <V : ViewForViewModel where V.ViewModelType : AnyObject> (vType : V.Type)(viewModel: V.ViewModelType) -> V {
    let view = vType(viewModel: viewModel)
    
    let v = view as! UIViewController
    VMTracker.append(viewModel, view: v)
    
    return view
}

// Composition

/// Wrap operator
///
/// For given factory function using given wrapper function it returns new factory function.
/// It's useful for placing ViewForViewModel inside another content view.
public func *> <T, V, V2>(factory: T -> V, wrapper: V -> V2) -> T -> V2 {
    return {
        let innerView = factory($0)
        return wrapper(innerView)
    }
}

// Wraps given view controller in navigation controller and returns it.
public func withinNavView(innerView: UIViewController) -> UINavigationController {
    return NavigationGroupView(rootViewController: innerView)
}

/// Present do two things:
///
/// -- Denotes ViewForViewModel's we want to use.
///
/// -- Aggregates given factory functions in one single factory function which takes as many arguments as factory functions provided and returns array of views.
public func present<T, V : UIViewController>(f : T -> V) -> T -> V {
    return f
}

public func present<T0, V0 : UIViewController, T1, V1: UIViewController>(f0: T0 -> V0, f1: T1 -> V1)(vm0: T0, vm1: T1) -> [UIViewController] {
    return [f0(vm0), f1(vm1)]
}

public func present<T0, V0 : UIViewController, T1, V1: UIViewController, T2, V2: UIViewController>(f0: T0 -> V0, f1: T1 -> V1, f2: T2 -> V2)(vm0: T0, vm1: T1, vm2: T2) -> [UIViewController] {
    return [f0(vm0), f1(vm1), f2(vm2)]
}

// For given GroupView type returns wrapper function.
public func within<GV : GroupView>(gvType: GV.Type)(views: [UIViewController]) -> GV.GroupViewType {
    return gvType.assemble(views)
}

// Transition

/// Creates navigation item for given factory and transition.
public func withTransition<ArgsType>(t: Transition)(factory: ArgsType -> UIViewController) -> (sender: AnyObject) -> (ArgsType) -> () {
    return createNavItem(factory, t)
}

/// Creates root View.
public func asRoot<ArgsType>(factory: ArgsType -> UIViewController) -> (ArgsType) -> () {
    return withTransition(Transitions.root)(factory: factory) *> noSender
}

func createNavItem<ArgsType> (factory: ArgsType -> UIViewController, transition: Transition) -> (sender: AnyObject) -> (ArgsType) -> () {
    return { s in
        return { args in
            let toView = factory(args)
            let fromView = VMTracker.getFromView(s) ?? UIViewController()
            transition(from: fromView, to: toView)
        }
    }
}

func noSender<ArgsType>(navItem: (sender: AnyObject) -> ArgsType -> ()) -> ArgsType -> () {
    return navItem(sender: dummyViewModel)
}

func goBack(fromView: UIViewController) {
    if let nc = fromView.navigationController where nc.topViewController == fromView {
        nc.popViewControllerAnimated(true)
    } else if fromView.presentingViewController?.presentedViewController == fromView {
        fromView.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

public func goBack(viewModel: AnyObject) {
    if let v = VMTracker.getFromView(viewModel) {
        goBack(v)
    }
}

class DummyViewModel {}
let dummyViewModel = DummyViewModel()

// VM & V tracking

class VMEntry {
    weak var vm: AnyObject?
    weak var view: UIViewController?
    
    init (vm: AnyObject, view: UIViewController) {
        self.vm = vm
        self.view = view
    }
}

class VMTracker {
    static var entries: [VMEntry] = []
    
    static func append(vm: AnyObject, view: UIViewController) {
        entries.append(VMEntry(vm: vm, view: view))
    }
    
    static func getFromView(sender: AnyObject) -> UIViewController? {
        cleanDeadEntries()
        return entries.filter({ $0.vm === sender }).first?.view
    }
    
    static func getViewModel(view: UIViewController) -> AnyObject? {
        cleanDeadEntries()
        return entries.filter({ $0.view == view }).first?.vm
    }
    
    static func cleanDeadEntries() {
        entries = entries.filter {
            $0.vm != nil && $0.view != nil
        }
    }
}
