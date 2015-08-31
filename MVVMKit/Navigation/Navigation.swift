//
//  AltRouting.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 07.05.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

// present(!View.self).within(NavigationView.self).asRoot()
// present(!View.self, !View2.self).within(SplitView.self).with(Transition.show)
// present(!View.self).asPopoverOn(View2.self) { presentingView, popover in ... }

public typealias Transition = (from: UIViewController, to: UIViewController) -> ()

// Creation

prefix operator ! {}

/// Factory operator
///
/// For given ViewForViewModel type it returns factory function which takes View Model and returns View binded to it.
public prefix func ! <V : ViewForViewModel where V: UIViewController> (vType : V.Type)(viewModel: V.ViewModelType) -> V {
    let view = vType.init()
    return afterViewInstantiated(view, viewModel: viewModel)
}

public prefix func ! <V : SBViewForViewModel where V: UIViewController> (vType : V.Type)(viewModel: V.ViewModelType) -> V {
    let (sbID, viewID) = vType.sbInfo
    let sb = UIStoryboard(name: sbID, bundle: nil)
    let view = sb.instantiateViewControllerWithIdentifier(viewID) as! V
    return afterViewInstantiated(view, viewModel: viewModel)
}

func afterViewInstantiated <V : ViewForViewModel where V: UIViewController>(var view : V, viewModel: V.ViewModelType) -> V {
    view.viewModel = viewModel
    
    VMTracker.sharedInstance.append(view)
    
    return view
}

/// Present do two things:
///
/// -- Denotes ViewForViewModel's we want to use.
///
/// -- Aggregates given factory functions in one single factory function which takes as many arguments as factory functions provided and returns array of views.
public func present<V : ViewForViewModel where V: UIViewController>(factory: (V.ViewModelType) -> V) -> ViewFactory<V, V.ViewModelType> {
    return ViewFactory(factory: factory)
}

public func present<V0 : ViewForViewModel, V1: ViewForViewModel where V0: UIViewController, V1: UIViewController>(f0: V0.ViewModelType -> V0, f1: V1.ViewModelType -> V1) -> ViewsFactory<(vm0: V0.ViewModelType, vm1: V1.ViewModelType)> {
    return ViewsFactory { args in
        [f0(args.vm0), f1(args.vm1)]
    }
}

public func present<V0 : ViewForViewModel, V1: ViewForViewModel, V2: ViewForViewModel where V0: UIViewController, V1: UIViewController, V2: UIViewController>(f0: V0.ViewModelType -> V0, f1: V1.ViewModelType -> V1, f2: V2.ViewModelType -> V2) -> ViewsFactory<(vm0: V0.ViewModelType, vm1: V1.ViewModelType, vm2: V2.ViewModelType)> {
    return ViewsFactory { args in
        [f0(args.vm0), f1(args.vm1), f2(args.vm2)]
    }
}

public struct ViewFactory<V: UIViewController, ArgsType> {
    let factory: (ArgsType) -> V
    
    /// Incorporates view into group view and returns factory for this new hierarchy.
    public func within<GV : GroupView>(gvType: GV.Type) -> ViewFactory<GV.GroupViewType, ArgsType> {
        return ViewFactory<GV.GroupViewType, ArgsType> { vm in
            let contentView = self.factory(vm)
            return gvType.assemble([contentView])
        }
    }
    
    /// Wraps given view into navigation controller and returns factory for this new hierarchy.
    public func withinNavView() -> ViewFactory<UINavigationController, ArgsType> {
        return ViewFactory<UINavigationController, ArgsType> { vm in
            NavigationGroupView(rootViewController: self.factory(vm))
        }
    }
    
    /// Set this view as root view.
    public func asRoot() -> (ArgsType) -> () {
        return { args in
            let rootView = self.factory(args)
            let window = UIApplication.sharedApplication().delegate?.window!
            window?.rootViewController = rootView
            window?.makeKeyAndVisible()
        }
    }
    
    /// Attaches view to screen with given transition.
    public func withTransition(t: Transition) -> (sender: AnyViewModel) -> (ArgsType) -> () {
        return { s in
            return { args in
                let toView = self.factory(args)
                let fromView = VMTracker.sharedInstance.getViewForViewModel(s)!
                t(from: fromView, to: toView)
            }
        }
    }
    
    public func withSegue(segueId: String, argsMapper: (ArgsType) -> [AnyObject]) -> (sender: AnyViewModel) -> (ArgsType) -> () {
        return { s in
            return { args in
                // don't using factory because Storyboard creates hierarchy
                let fromView = VMTracker.sharedInstance.getViewForViewModel(s)!
                fromView.performSegueWithIdentifier(segueId, sender: argsMapper(args))
            }
        }
    }
    
    /// Present view as popover above another view.
    public func asPopoverOn<V: UIViewController>(v: V.Type, popoverSetup: (V, UIPopoverPresentationController) -> ()) -> (sender: AnyViewModel) -> (ArgsType) -> () {
        
        return { s in
            return { args in
                let view = self.factory(args)
                view.modalPresentationStyle = .Popover
                let popoverPC = view.popoverPresentationController!
                let presentingVC = VMTracker.sharedInstance.getViewForViewModel(s) as! V
                if let delegate = presentingVC as? UIPopoverPresentationControllerDelegate {
                    popoverPC.delegate = delegate
                }
                
                popoverSetup(presentingVC, popoverPC)
                
                presentingVC.presentViewController(view, animated: true, completion: nil)
            }
        }
    }
}

public struct ViewsFactory<ArgsType> {
    let factory: (ArgsType) -> [UIViewController]
    
    public func within<GV : GroupView>(gvType: GV.Type) -> ViewFactory<GV.GroupViewType, ArgsType> {
        return ViewFactory<GV.GroupViewType, ArgsType> { args in
            let contentViews = self.factory(args)
            return gvType.assemble(contentViews)
        }
    }
}

func goBack(fromView: UIViewController) {
    if let nc = fromView.navigationController where nc.topViewController == fromView {
        nc.popViewControllerAnimated(true)
    } else if fromView.presentingViewController?.presentedViewController == fromView {
        fromView.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    } else if let _ = fromView.popoverPresentationController {
        fromView.dismissViewControllerAnimated(true, completion: nil)
    }
}

public func goBack(viewModel: AnyViewModel) {
    if let v = VMTracker.sharedInstance.getViewForViewModel(viewModel) {
        goBack(v)
    }
}

// VM & V tracking

final class VMTracker {
    static let sharedInstance = VMTracker()
    
    var entries: [AnyViewForAnyViewModel] = []
    
    func append<V: ViewForViewModel where V: AnyObject>(view: V) {
        entries.append(AnyViewForViewModel(weakBase: view))
    }
    
    func getViewForViewModel(vm: AnyViewModel) -> UIViewController? {
        cleanDeadEntries()
        
        var result: UIViewController? = nil
        for entry in entries {
            entry.strongify { _ in
                if entry.anyViewModel == vm {
                    result = (entry.value as! UIViewController)
                }
            }
        }
        return result
    }
    
    func getViewModelForView(view: UIViewController) -> AnyViewModel? {
        cleanDeadEntries()
        
        var result: AnyViewModel? = nil
        for entry in entries {
            entry.strongify { _ in
                if entry.value === view {
                    result = entry.anyViewModel
                }
            }
        }
        return result
    }
    
    func cleanDeadEntries() {
        entries = entries.filter {
            $0.strongify({ _ in })
        }
    }
}