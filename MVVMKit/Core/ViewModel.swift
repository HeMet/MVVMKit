//
//  ViewModel.swift
//  MVVMKit
//
//  Created by Eugene Gubin on 30.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

// Any view model should support this protocol
public protocol ViewModel: Equatable { }

public typealias ViewModelEventHandler = (Any) -> ()

// Define view model that has some disposal logic and ability to inform parent view model about disposal
public protocol DisposableViewModel {
    var onDisposed: ViewModelEventHandler? { get set }
    func dispose()
    func handleDidDisposeViewModel(viewModel: Any)
}

public extension DisposableViewModel {
    func dispose() {
        onDisposed?(self)
    }
    
    func handleDidDisposeViewModel(viewModel: Any) {
        // do nothing by default
    }
    
    func child<VM: DisposableViewModel>(@noescape factory: () -> VM) -> VM {
        var vm = factory()
        vm.onDisposed = handleDidDisposeViewModel
        return vm
    }
}

public protocol ViewModelWithID: ViewModel, UniqueID {
    
}