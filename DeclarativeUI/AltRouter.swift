//
//  AltRouter.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 07.05.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

public class AltRouter : NSObject {
    private class VMEntry {
        weak var vm: ViewModel?
        weak var view: UIViewController?
        
        init (vm: ViewModel, view: UIViewController) {
            self.vm = vm
            self.view = view
        }
    }
    
    private class DummyModel : ViewModel {
        var router : Router!
    }
    
    public static let NO_MODEL : ViewModel = DummyModel()
    
    private var knownVM = [VMEntry]()
    
    public var onViewModelBinded : ((ViewModel) -> ())?
    
    func navigate(sender: ViewModel, toView: UIViewController, withTransition: Router.Transition) {
        cleanDeadVM()
        
        //todo: add check when from is needed or not
        let from = getFromView(sender) ?? UIViewController()
        //todo: register VM-V pair
        withTransition(from, toView, "")
    }
    
    private func getFromView(sender: ViewModel) -> UIViewController? {
        return knownVM.filter({ $0.vm === sender }).first?.view
    }
    
//    private func internalOnViewModelBinded(viewModel: ViewModel) {
//        viewModel.router = self
//        
//        onViewModelBinded?(viewModel)
//    }
    
    private func cleanDeadVM() {
        knownVM = knownVM.filter {
            $0.vm != nil && $0.view != nil
        }
    }
}
