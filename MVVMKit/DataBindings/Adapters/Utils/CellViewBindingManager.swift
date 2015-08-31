//
//  CellViewBindingManager.swift
//  MVVMKit
//
//  Created by Евгений Губин on 15.07.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

public class CellViewBindingManager {
    typealias Binding = (AnyViewModel, NSIndexPath) -> UITableViewCell
    public typealias BindingCallback = (UITableViewCell, NSIndexPath) -> ()
    
    let templateCellWidthContraintId = "CVBM_templace_cell_width_constraint"
    
    unowned var tableView: UITableView
    var bindings: [String:Binding] = [:]
    var templateCells: [String: AnyViewForAnyViewModel] = [:]
    
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
        registerTemplateCell(viewType)
    }
    
    public func register<V: UITableViewCell where V: BindableCellView, V: NibSource>(viewType: V.Type) {
        if tableView.dequeueReusableCellWithIdentifier(V.CellIdentifier) == nil {
            let nib = UINib(nibName: V.NibIdentifier, bundle: nil)
            tableView.registerNib(nib, forCellReuseIdentifier: V.CellIdentifier)
        }
        
        registerBinding(viewType)
        registerTemplateCell(viewType)
    }
    
    func registerBinding<V: BindableCellView where V: UITableViewCell>(viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        
        bindings[typeName] = { [unowned self] viewModel, indexPath in
            var view = self.tableView.dequeueReusableCellWithIdentifier(V.CellIdentifier, forIndexPath: indexPath) as! V
            
            view.viewModel = viewModel.value as! V.ViewModelType
            
            self.onWillBind?(view, indexPath)
            view.bindToViewModel()
            self.onDidBind?(view, indexPath)
            
            return view
        }
    }
    
    func registerTemplateCell<V: BindableCellView where V: UITableViewCell>(viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        
        let templateCell = tableView.dequeueReusableCellWithIdentifier(V.CellIdentifier) as! V
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        templateCells[typeName] = AnyViewForViewModel(base: templateCell)
    }
    
    func calculateHeightForTemplateCell(cell: AnyViewForAnyViewModel, viewModel: AnyViewModel, indexPath: NSIndexPath) -> CGSize {
        let templateCell = cell.value as! UITableViewCell
        
        cell.anyViewModel = viewModel
        
        applyWidthContraint(templateCell.contentView, width: tableView.bounds.width)
        
        self.onWillBind?(templateCell, indexPath)
        cell.bindToViewModel()
        self.onDidBind?(templateCell, indexPath)

        templateCell.bounds = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: templateCell.bounds.height)
        
        templateCell.setNeedsLayout()
        templateCell.layoutIfNeeded()
        
        var size = templateCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        size.height++
        
        return size
    }
    
    func applyWidthContraint(contentView: UIView, width: CGFloat) {
        let constraints = contentView.constraints 
        let oldWC = constraints.filter { $0.identifier == self.templateCellWidthContraintId }.first
        if let wc = oldWC {
            contentView.removeConstraint(wc)
        }
        
        let newWC = NSLayoutConstraint(item: contentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: width)
        newWC.identifier = templateCellWidthContraintId
        
        contentView.addConstraint(newWC)
    }
    
    public func unregister<V: ViewForViewModel>(viewType: V.Type) {
        let typeName = nameOfType(V.ViewModelType.self)
        bindings[typeName] = nil
    }
    
    func bindViewModel(viewModel: AnyViewModel, indexPath: NSIndexPath) -> UITableViewCell {
        let typeName = nameOfInstance(viewModel.value)
        if let binding = bindings[typeName] {
            return binding(viewModel, indexPath)
        }
        fatalError("Unknown view model type")
    }
    
    func sizeForViewModel(viewModel: AnyViewModel, atIndexPath: NSIndexPath) -> CGSize {
        let typeName = nameOfInstance(viewModel.value)
        if let templateCell = templateCells[typeName] {
            return calculateHeightForTemplateCell(templateCell, viewModel: viewModel, indexPath: atIndexPath)
        }
        fatalError("Unknown view model type")
    }
    
    func nameOfInstance(obj: Any) -> String {
        return "\(obj.dynamicType)"
    }
    
    func nameOfType<T>(type: T.Type) -> String {
        return "\(type)"
    }
    
    deinit {
        print("deinit bindings manager")
    }
}