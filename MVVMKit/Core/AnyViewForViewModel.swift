//
//  AnyViewForViewModel.swift
//  MVVMKit
//
//  Created by Евгений Губин on 30.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import UIKit

// Type-erased version of ViewForViewModel

class AnyViewForViewModel<ViewModelType: ViewModel>: AnyViewForAnyViewModel, ViewForViewModel {
    let base: _AnyViewForViewModelBoxBase<ViewModelType>
    
    init<V: ViewForViewModel where V: AnyObject, V.ViewModelType == ViewModelType>(base: V) {
        self.base = _AnyViewForViewModelBox(base: base)
    }
    
    var viewModel: ViewModelType! {
        get {
            return base.viewModel
        }
        set {
            base.viewModel = newValue
        }
    }
    
    override var anyViewModel: Any {
        get {
            return viewModel
        }
        set {
            viewModel = newValue as! ViewModelType
        }
    }
    
    // Could be either UIView or UIViewController
    override var view: AnyObject {
        return base.view
    }
    
    override func bindToViewModel() {
        base.bindToViewModel()
    }
}

// Completely type-erased version of ViewForViewModel

class AnyViewForAnyViewModel {
    
    var view: AnyObject {
        fatalError()
    }
    
    var anyViewModel: Any {
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
}

class _AnyViewForViewModelBoxBase<ViewModelType: ViewModel>: ViewForViewModel {

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
}

class _AnyViewForViewModelBox<V: ViewForViewModel where V: AnyObject>: _AnyViewForViewModelBoxBase<V.ViewModelType> {
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
}