//
//  ViewBindingManager.swift
//  MVVMKit
//
//  Created by Евгений Губин on 15.07.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public class ViewBindingManager {
    typealias Binding = (AnyObject) -> UIView
    public typealias BindingCallback = (UIView) -> ()
    
    var bindings: [String:Binding] = [:]
    
    public var onWillBind: BindingCallback?
    public var onDidBind: BindingCallback?
    
    public func registerView<V: ViewForViewModel where V: UIView>(viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        bindings[typeName] = { [unowned self] viewModel in
            let view = viewType.init()
            view.viewModel = viewModel as! V.ViewModelType
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
    
    func bindViewModel(viewModel: AnyObject) -> UIView {
        if let view = tryBindViewModel(viewModel) {
            return view
        }
        fatalError("Unknown view model type")
    }
    
    func canBindViewModel(viewModel: AnyObject) -> Bool {
        let typeName = nameOfType(viewModel)
        return bindings[typeName] != nil
    }
    
    func tryBindViewModel(viewModel: AnyObject) -> UIView? {
        let typeName = nameOfType(viewModel)
        if let binding = bindings[typeName] {
            return binding(viewModel)
        }
        return nil
    }
    
    func nameOfType(obj: AnyObject) -> String {
        return "\(obj.dynamicType)"
    }
    
    func nameOfType<T>(type: T.Type) -> String {
        return "\(type)"
    }
}