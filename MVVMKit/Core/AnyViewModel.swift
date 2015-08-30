//
//  AnyViewModel.swift
//  MVVMKit
//
//  Created by Евгений Губин on 30.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

public class AnyViewModel: ViewModel {
    private let base: _AnyViewModelBoxBase
    
    public init<VM: ViewModel>(viewModel: VM) {
        base = _ViewModelBox(viewModel: viewModel)
    }
    
    var value: Any {
        return base.value
    }
}

public func ==(l: AnyViewModel, r: AnyViewModel) -> Bool {
    return l.base.equalsTo(r.base)
}

prefix operator ! {}

public prefix func!<VM: ViewModel>(vm: VM) -> AnyViewModel {
    return AnyViewModel(viewModel: vm)
}

private class _ViewModelBox<VM: ViewModel>: _AnyViewModelBoxBase {
    let base: VM
    
    init(viewModel: VM) {
        base = viewModel
    }
    
    override var value: Any {
        return base
    }
    
    override func equalsTo(other: _AnyViewModelBoxBase) -> Bool {
        if let other = other as? _ViewModelBox<VM> {
            return base == other.base
        }
        return false
    }
}

private class _AnyViewModelBoxBase: ViewModel {
    var value: Any {
        fatalError()
    }
    
    func equalsTo(other: _AnyViewModelBoxBase) -> Bool {
        fatalError()
    }
}

private func ==(l: _AnyViewModelBoxBase, r: _AnyViewModelBoxBase) -> Bool {
    return l.equalsTo(r)
}