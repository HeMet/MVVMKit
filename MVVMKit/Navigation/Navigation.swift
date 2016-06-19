//
//  AltRouting.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 07.05.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

public typealias Transition = (from: UIViewController, to: UIViewController) -> ()

// Creation

extension ViewForViewModel where Self: UIViewController {
    public static func presented() -> ViewFactory<Self, ViewModelType> {
        return ViewFactory(factory: { Self.bindedTo($0) })
    }
    
    public static func bindedTo(_ viewModel: ViewModelType) -> Self {
        var vc: Self
        
        // It is not so clean as to has dedicated extension for each source type,
        // but this way we ain't forced to implement each method that uses `create` three times
        if let sbsType = self as? StoryboardSource.Type {
            vc = createFromSB(sbsType.sbName, sbsType.sbIdentifier)
            
        } else if let nsType = self as? NibSource.Type {
            vc = Self.init(nibName: nsType.NibIdentifier, bundle: nil)
            
        } else {
            vc = Self()
        }
        
        vc.viewModel = viewModel
        
        VMTracker.sharedInstance.append(vc)
        
        return vc
    }
    
    static func createFromSB(_ sbID: String, _ viewID: String) -> Self {
        let sb = UIStoryboard(name: sbID, bundle: nil)
        return sb.instantiateViewController(withIdentifier: viewID) as! Self
    }
}


extension GroupView {
    public static func with<Args>(_ callback: (Args) -> [UIViewController]) -> ViewFactory<GroupViewType, Args> {
        let factory = { (args: Args) -> GroupViewType in
            let children = callback(args)
            return Self.assemble(children)
        }
        return ViewFactory(factory: factory)
    }
    
    public static func with<Args>(_ callback: (Args) -> UIViewController) -> ViewFactory<GroupViewType, Args> {
        let factory = { (args: Args) -> GroupViewType in
            let child = callback(args)
            return Self.assemble([child])
        }
        return ViewFactory(factory: factory)
    }
}


public struct ViewFactory<V: UIViewController, ArgsType> {
    let factory: (ArgsType) -> V
    
    public func presented() -> ViewFactory<V, ArgsType> {
        return self
    }
    
    /// Set this view as root view.
    public func asRoot() -> (ArgsType) -> () {
        return { args in
            let rootView = self.factory(args)
            let window = UIApplication.shared().delegate?.window!
            window?.rootViewController = rootView
            window?.makeKeyAndVisible()
        }
    }
    
    /// Attaches view to screen with given transition.
    public func withTransition(_ t: Transition) -> (sender: AnyViewModel) -> (ArgsType) -> () {
        return { s in
            return { args in
                let toView = self.factory(args)
                let fromView = VMTracker.sharedInstance.getViewForViewModel(s)!
                t(from: fromView, to: toView)
            }
        }
    }
    
    public func withSegue(_ segueId: String, argsMapper: (ArgsType) -> [AnyObject]) -> (sender: AnyViewModel) -> (ArgsType) -> () {
        return { s in
            return { args in
                // don't using factory because Storyboard creates hierarchy
                let fromView = VMTracker.sharedInstance.getViewForViewModel(s)!
                fromView.performSegue(withIdentifier: segueId, sender: argsMapper(args))
            }
        }
    }
    
    /// Present view as popover above another view.
    public func asPopoverOn<V: UIViewController>(_ v: V.Type, popoverSetup: (V, UIPopoverPresentationController) -> ()) -> (sender: AnyViewModel) -> (ArgsType) -> () {
        
        return { s in
            return { args in
                let view = self.factory(args)
                view.modalPresentationStyle = .popover
                let popoverPC = view.popoverPresentationController!
                let presentingVC = VMTracker.sharedInstance.getViewForViewModel(s) as! V
                if let delegate = presentingVC as? UIPopoverPresentationControllerDelegate {
                    popoverPC.delegate = delegate
                }
                
                popoverSetup(presentingVC, popoverPC)
                
                presentingVC.present(view, animated: true, completion: nil)
            }
        }
    }
}

extension ViewModel {
    public func goBack() {
        if let v = VMTracker.sharedInstance.getViewForViewModel(!self) {
            goBack(v)
        }
    }
    
    func goBack(_ fromView: UIViewController) {
        if let nc = fromView.navigationController where nc.topViewController == fromView {
            nc.popViewController(animated: true)
        } else if fromView.presentingViewController?.presentedViewController == fromView {
            fromView.presentingViewController?.dismiss(animated: true, completion: nil)
        } else if let _ = fromView.popoverPresentationController {
            fromView.dismiss(animated: true, completion: nil)
        }
    }
}

// VM & V tracking

final class VMTracker {
    static let sharedInstance = VMTracker()
    
    var entries: [AnyViewForAnyViewModel] = []
    
    func append<V: ViewForViewModel where V: AnyObject>(_ view: V) {
        entries.append(AnyViewForViewModel(weakBase: view))
    }
    
    func getViewForViewModel(_ vm: AnyViewModel) -> UIViewController? {
        cleanDeadEntries()
        
        var result: UIViewController? = nil
        for entry in entries {
            _ = entry.strongify { _ in
                if entry.anyViewModel == vm {
                    result = (entry.value as! UIViewController)
                }
            }
        }
        return result
    }
    
    func getViewModelForView(_ view: UIViewController) -> AnyViewModel? {
        cleanDeadEntries()
        
        var result: AnyViewModel? = nil
        for entry in entries {
            _ = entry.strongify { _ in
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
