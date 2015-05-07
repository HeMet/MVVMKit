//
//  AltRouting.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 07.05.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

protocol MultiView {
    typealias MultiViewType : UIViewController
    static func assemble(views: [UIViewController]) -> MultiViewType
}

class TabBarView : MultiView {
    static func assemble(views: [UIViewController]) -> UITabBarController {
        let tb = UITabBarController()
        tb.viewControllers = views
        return tb
    }
}

extension UISplitViewController : MultiView {
    static func assemble(views: [UIViewController]) -> UISplitViewController {
        let splitV = UISplitViewController()
        splitV.viewControllers = views
        return splitV
    }
}

func bind<V : ViewForViewModel>(vType : V.Type) -> (V.ViewModelType) -> UIViewController {
    return {
        vType(viewModel: $0) as! UIViewController
    }
}

func bind<V1 : ViewForViewModel, V2: ViewForViewModel>(v1Type: V1.Type, v2Type: V2.Type) -> (V1.ViewModelType, V2.ViewModelType) -> [UIViewController] {
    let b1 = bind(V1)
    let b2 = bind(V2)
    
    return { args in
        let v1 = b1(args.0)
        let v2 = b2(args.1)
        return [v1, v2]
    }
}

func bind<V1 : ViewForViewModel, V2: ViewForViewModel, V3: ViewForViewModel>(v1Type: V1.Type, v2Type: V2.Type, v3Type: V3.Type) -> (V1.ViewModelType, V2.ViewModelType, V3.ViewModelType) -> [UIViewController] {
    let other = bind(V1.self, V2.self)
    let b3 = bind(V3)
    
    return { args in
        var result = other((args.0, args.1))
        let v = b3(args.2)
        result.append(v)
        return result
    }
}

func toGroupView<GV: MultiView, ArgsType where GV: UIViewController> (bindings: ArgsType -> [UIViewController], gvType: GV.Type) -> ArgsType -> GV {
    return { args in
        let views = bindings(args)
        return GV.assemble(views) as! GV
    }
}

func withTransition<ArgsType, V> (builder: ArgsType -> V, transition: Router.Transition) -> (ArgsType -> V, Router.Transition) {
    return (builder, transition)
}

func route<ArgsType, V>(router: Router)(args: (ArgsType -> V, Router.Transition)) -> ArgsType -> () {
    return { innerArgs in
        let (builder, transition) = args
        let view = builder(innerArgs)
        // *router* perform *transition* to *view*
    }
}

infix operator |> {
    associativity left

    // Bind tighter than assignment, but looser than everything else.
    precedence 95
}

func |> <ArgsType, GV : MultiView where GV: UIViewController>(bindings: ArgsType -> [UIViewController], gv: GV.Type) -> ArgsType -> GV {
    return toGroupView(bindings, GV.self)
}

func toGroupView<GV: MultiView where GV: UIViewController>(gvType: GV.Type) -> GV.Type {
    return gvType
}

func |> <ArgsType, V> (builder: ArgsType -> V, transition: Router.Transition) -> (ArgsType -> V, Router.Transition) {
    return withTransition(builder, transition)
}

func withTransition(t: Router.Transition) -> Router.Transition {
    return t
}