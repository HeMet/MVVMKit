//
//  ViewBindingManager.swift
//  MVVMKit
//
//  Created by Евгений Губин on 15.07.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public class ViewBindingManager {
    typealias Binding = (AnyViewModel) -> UIView
    public typealias BindingCallback = (UIView) -> ()
    
    var bindings: [String:Binding] = [:]
    
    public var onWillBind: BindingCallback?
    public var onDidBind: BindingCallback?
    
    public func registerView<V: ViewForViewModel where V: UIView>(viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        bindings[typeName] = { [unowned self] viewModel in
            var view = viewType.init()
            view.viewModel = viewModel.value as! V.ViewModelType
            self.onWillBind?(view)
            view.bindToViewModel()
            self.onDidBind?(view)
            return view
        }
    }
    
    public func unregisterView<V: ViewForViewModel>(viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        bindings[typeName] = nil
    }
    
    func bindViewModel(viewModel: AnyViewModel) -> UIView {
        if let view = tryBindViewModel(viewModel) {
            return view
        }
        fatalError("Unknown view model type")
    }
    
    func canBindViewModel(viewModel: AnyViewModel) -> Bool {
        let typeName = nameOfType(viewModel.value)
        return bindings[typeName] != nil
    }
    
    func tryBindViewModel(viewModel: AnyViewModel) -> UIView? {
        let typeName = nameOfType(viewModel.value)
        if let binding = bindings[typeName] {
            return binding(viewModel)
        }
        return nil
    }
    
    func nameOfType(obj: Any) -> String {
        return "\(obj.dynamicType)"
    }
    
    func nameOfType<T>(type: T.Type) -> String {
        return "\(type)"
    }
}