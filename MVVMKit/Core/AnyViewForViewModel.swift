//
//  AnyViewForViewModel.swift
//  MVVMKit
//
//  Created by Евгений Губин on 30.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import UIKit

// Type-erased version of ViewForViewModel

public class AnyViewForViewModel<ViewModelType: ViewModel>: AnyViewForAnyViewModel, ViewForViewModel {
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
    
    override func setAnyViewModel(viewModel: Any) {
        base.viewModel = viewModel as! ViewModelType
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
    override var view: AnyObject {
        return base.view
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
    
    var view: AnyObject {
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
    
    func setAnyViewModel(viewModel: Any) {
        fatalError()
    }
    
    public func bindToViewModel() {
        fatalError()
    }
    
    func strongify(@noescape callback: (AnyObject) -> ()) -> Bool {
        fatalError()
    }
}

private class _AnyViewForViewModelBoxBase<ViewModelType: ViewModel>: ViewForViewModel {

    var view: AnyObject {
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

private class _AnyViewForViewModelBox<V: ViewForViewModel where V: AnyObject>: _AnyViewForViewModelBoxBase<V.ViewModelType> {
    var base: V
    
    init(base: V) {
        self.base = base
    }
    
    override var view: AnyObject {
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

private class _WeakAnyViewForViewModelBox<V: ViewForViewModel where V: AnyObject>: _AnyViewForViewModelBoxBase<V.ViewModelType> {
    weak var base: V?
    
    init(base: V) {
        self.base = base
    }
    
    override var view: AnyObject {
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