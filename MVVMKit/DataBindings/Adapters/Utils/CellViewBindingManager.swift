//
//  CellViewBindingManager.swift
//  MVVMKit
//
//  Created by Евгений Губин on 15.07.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

public class CellViewBindingManager {
    typealias Binding = (AnyViewModel, IndexPath) -> UITableViewCell
    public typealias BindingCallback = (UITableViewCell, IndexPath) -> ()
    
    let templateCellWidthContraintId = "CVBM_templace_cell_width_constraint"
    
    unowned var tableView: UITableView
    var bindings: [String:Binding] = [:]
    var templateCells: [String: AnyViewForAnyViewModel] = [:]
    
    public var onWillBind: BindingCallback?
    public var onDidBind: BindingCallback?
    
    public init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    public func register<V: UITableViewCell where V: CellViewForViewModel>(_ viewType: V.Type) {
        if V.dequeueFrom(tableView) == nil {
            tableView.register(V.self, forCellReuseIdentifier: V.CellIdentifier)
        }
        
        registerBinding(viewType)
        registerTemplateCell(viewType)
    }
    
    public func register<V: UITableViewCell where V: CellViewForViewModel, V: NibSource>(_ viewType: V.Type) {
        if V.dequeueFrom(tableView) == nil {
            let nib = UINib(nibName: V.NibIdentifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: V.CellIdentifier)
        }
        
        registerBinding(viewType)
        registerTemplateCell(viewType)
    }
    
    func registerBinding<V: CellViewForViewModel where V: UITableViewCell>(_ viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        
        bindings[typeName] = { [unowned self] viewModel, indexPath in
            var view = V.dequeueFrom(self.tableView, forIndexPath: indexPath)
            
            view.viewModel = viewModel.value as! V.ViewModelType
            
            self.onWillBind?(view, indexPath)
            view.bindToViewModel()
            self.onDidBind?(view, indexPath)
            
            return view
        }
    }
    
    func registerTemplateCell<V: CellViewForViewModel where V: UITableViewCell>(_ viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        
        let templateCell = V.dequeueFrom(tableView)!
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        templateCells[typeName] = AnyViewForViewModel(base: templateCell)
    }
    
    func calculateHeightForTemplateCell(_ cell: AnyViewForAnyViewModel, viewModel: AnyViewModel, indexPath: IndexPath) -> CGSize {
        let templateCell = cell.value as! UITableViewCell
        
        cell.anyViewModel = viewModel
        
        applyWidthContraint(templateCell.contentView, width: tableView.bounds.width)
        
        self.onWillBind?(templateCell, indexPath)
        cell.bindToViewModel()
        self.onDidBind?(templateCell, indexPath)

        templateCell.bounds = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: templateCell.bounds.height)
        
        templateCell.setNeedsLayout()
        templateCell.layoutIfNeeded()
        
        var size = templateCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        size.height += 1
        
        return size
    }
    
    func applyWidthContraint(_ contentView: UIView, width: CGFloat) {
        let constraints = contentView.constraints 
        let oldWC = constraints.filter { $0.identifier == self.templateCellWidthContraintId }.first
        if let wc = oldWC {
            contentView.removeConstraint(wc)
        }
        
        let newWC = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        newWC.identifier = templateCellWidthContraintId
        
        contentView.addConstraint(newWC)
    }
    
    public func unregister<V: ViewForViewModel>(_ viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        bindings[typeName] = nil
    }
    
    func bindViewModel(_ viewModel: AnyViewModel, indexPath: IndexPath) -> UITableViewCell {
        let typeName = nameOfInstance(viewModel.value)
        if let binding = bindings[typeName] {
            return binding(viewModel, indexPath)
        }
        fatalError("Unknown view model type")
    }
    
    func sizeForViewModel(_ viewModel: AnyViewModel, atIndexPath: IndexPath) -> CGSize {
        let typeName = nameOfInstance(viewModel.value)
        if let templateCell = templateCells[typeName] {
            return calculateHeightForTemplateCell(templateCell, viewModel: viewModel, indexPath: atIndexPath)
        }
        fatalError("Unknown view model type")
    }
    
    func nameOfInstance(_ obj: Any) -> String {
        return "\(obj.dynamicType)"
    }
    
    func nameOfType<T>(_ type: T.Type) -> String {
        return "\(type)"
    }
    
    deinit {
        print("deinit bindings manager")
    }
}
