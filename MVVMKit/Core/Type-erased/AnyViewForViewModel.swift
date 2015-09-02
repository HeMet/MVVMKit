//
//  AnyViewForViewModel.swift
//  MVVMKit
//
//  Created by Евгений Губин on 30.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import UIKit

// Type-erased version of ViewForViewModel

public final class AnyViewForViewModel<ViewModelType: ViewModel>: AnyViewForAnyViewModel, ViewForViewModel {
    private let base: _AnyViewForViewModelBoxBase<ViewModelType>
    
    public init<V: ViewForViewModel where V: AnyObject, V.ViewModelType == ViewModelType>(base: V) {
        self.base = _AnyViewForViewModelBox(base: base)
    }
    
    init<V: ViewForViewModel where V: AnyObject, V.ViewModelType == ViewModelType>(weakBase: V) {
        self.base = _WeakAnyViewForViewModelBox(base: weakBase)
    }
    
    public var viewModel: ViewModelType! {
        get {
            return base.viewModel
        }
        set {
            base.viewModel = newValue
        }
    }
    
    override var anyViewModel: AnyViewModel {
        get {
            return AnyViewModel(viewModel: viewModel)
        }
        set {
            base.viewModel = newValue.value as! ViewModelType
        }
    }

    // Could be either UIView or UIViewController
    override var value: AnyObject {
        return base.value
    }
    
    public override func bindToViewModel() {
        base.bindToViewModel()
    }
    
    override func strongify(@noescape callback: (AnyObject) -> ()) -> Bool {
        return base.strongify(callback)
    }
}

// Completely type-erased version of ViewForViewModel

public class AnyViewForAnyViewModel {
    
    var value: AnyObject {
        fatalError()
    }
    
    var anyViewModel: AnyViewModel {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
    
    public func bindToViewModel() {
        fatalError()
    }
    
    func strongify(@noescape callback: (AnyObject) -> ()) -> Bool {
        fatalError()
    }
}

private class _AnyViewForViewModelBoxBase<ViewModelType: ViewModel>: ViewForViewModel {

    var value: AnyObject {
        fatalError()
    }
    
    var viewModel: ViewModelType! {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
    
    func bindToViewModel() {
        fatalError()
    }
    
    func strongify(@noescape callback: (AnyObject) -> ()) -> Bool {
        fatalError()
    }
}

private final class _AnyViewForViewModelBox<V: ViewForViewModel where V: AnyObject>: _AnyViewForViewModelBoxBase<V.ViewModelType> {
    var base: V
    
    init(base: V) {
        self.base = base
    }
    
    override var value: AnyObject {
        return base
    }
    
    override var viewModel: V.ViewModelType! {
        get {
            return base.viewModel
        }
        set {
            base.viewModel = newValue
        }
    }
    
    override func bindToViewModel() {
        base.bindToViewModel()
    }
    
    override func strongify(@noescape callback: (AnyObject) -> ()) -> Bool {
        callback(base)
        return true
    }
}

private final class _WeakAnyViewForViewModelBox<V: ViewForViewModel where V: AnyObject>: _AnyViewForViewModelBoxBase<V.ViewModelType> {
    weak var base: V?
    
    init(base: V) {
        self.base = base
    }
    
    override var value: AnyObject {
        return base!
    }
    
    override var viewModel: V.ViewModelType! {
        get {
            return base!.viewModel
        }
        set {
            base!.viewModel = newValue
        }
    }
    
    override func bindToViewModel() {
        base!.bindToViewModel()
    }
    
    override func strongify(@noescape callback: (AnyObject) -> ()) -> Bool {
        if let strongBase = base {
            callback(strongBase)
            return true
        }
        return false
    }
}