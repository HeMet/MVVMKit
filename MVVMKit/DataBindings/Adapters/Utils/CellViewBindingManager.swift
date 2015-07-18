//
//  CellViewBindingManager.swift
//  MVVMKit
//
//  Created by Евгений Губин on 15.07.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

public class CellViewBindingManager {
    typealias Binding = (AnyObject, NSIndexPath) -> UITableViewCell
    public typealias BindingCallback = (UITableViewCell, NSIndexPath) -> ()
    
    unowned(unsafe) var tableView: UITableView
    var bindings: [String:Binding] = [:]
    
    public var onWillBind: BindingCallback?
    public var onDidBind: BindingCallback?
    
    public init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    public func register<V: UITableViewCell where V: BindableCellView>(viewType: V.Type) {
        if tableView.dequeueReusableCellWithIdentifier(V.CellIdentifier) == nil {
            tableView.registerClass(V.self, forCellReuseIdentifier: V.CellIdentifier)
        }
        
        registerBinding(viewType)
    }
    
    public func register<V: UITableViewCell where V: BindableCellView, V: NibSource>(viewType: V.Type) {
        if tableView.dequeueReusableCellWithIdentifier(V.CellIdentifier) == nil {
            let nib = UINib(nibName: V.NibIdentifier, bundle: nil)
            tableView.registerNib(nib, forCellReuseIdentifier: V.CellIdentifier)
        }
        
        registerBinding(viewType)
    }
    
    func registerBinding<V: BindableCellView where V: UITableViewCell>(viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        
        bindings[typeName] = { [unowned self] viewModel, indexPath in
            let view = self.tableView.dequeueReusableCellWithIdentifier(V.CellIdentifier, forIndexPath: indexPath) as! V
            
            view.viewModel = viewModel as! V.ViewModelType
            
            self.onWillBind?(view, indexPath)
            view.bindToViewModel()
            self.onDidBind?(view, indexPath)
            
            return view
        }
    }
    
    public func unregister<V: ViewForViewModel>(viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        bindings[typeName] = nil
    }
    
    func bindViewModel(viewModel: AnyObject, indexPath: NSIndexPath) -> UITableViewCell {
        let typeName = nameOfType(viewModel)
        if let binding = bindings[typeName] {
            return binding(viewModel, indexPath)
        }
        fatalError("Unknown view model type")
    }
    
    func nameOfType(obj: AnyObject) -> String {
        return "\(obj.dynamicType)"
    }
    
    func nameOfType<T>(type: T.Type) -> String {
        return "\(type)"
    }
    
    deinit {
        println("deinit bindings manager")
    }
}