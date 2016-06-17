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
    
    public func registerView<V: ViewForViewModel where V: UIView>(_ viewType: V.Type) {
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
    
    public func unregisterView<V: ViewForViewModel>(_ viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        bindings[typeName] = nil
    }
    
    func bindViewModel(_ viewModel: AnyViewModel) -> UIView {
        if let view = tryBindViewModel(viewModel) {
            return view
        }
        fatalError("Unknown view model type")
    }
    
    func canBindViewModel(_ viewModel: AnyViewModel) -> Bool {
        let typeName = nameOfType(viewModel.value)
        return bindings[typeName] != nil
    }
    
    func tryBindViewModel(_ viewModel: AnyViewModel) -> UIView? {
        let typeName = nameOfType(viewModel.value)
        if let binding = bindings[typeName] {
            return binding(viewModel)
        }
        return nil
    }
    
    func nameOfType(_ obj: Any) -> String {
        return "\(obj.dynamicType)"
    }
    
    func nameOfType<T>(_ type: T.Type) -> String {
        return "\(type)"
    }
}
