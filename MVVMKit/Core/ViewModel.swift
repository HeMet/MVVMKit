//
//  ViewModel.swift
//  MVVMKit
//
//  Created by Eugene Gubin on 30.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public typealias ViewModelEventHandler = (ViewModel) -> ()

public protocol ViewModel : class {
    var onDisposed: ViewModelEventHandler? { get set }
    func dispose()
    func handleDidDisposeViewModel(viewModel: AnyObject)
}

public extension ViewModel {
    func dispose() {
        onDisposed?(self)
    }
    
    func handleDidDisposeViewModel(viewModel: AnyObject) {
        // do nothing by default
    }
    
    func child<VM: ViewModel>(@noescape factory: () -> VM) -> VM {
        let vm = factory()
        vm.onDisposed = handleDidDisposeViewModel
        return vm
    }
}