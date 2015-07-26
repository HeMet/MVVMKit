//
//  ViewForViewModel.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 06.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

public protocol ViewForViewModel {
    typealias ViewModelType: ViewModel
    typealias Factory = (ViewModelType) -> Self
    
    var viewModel: ViewModelType! { get set }
    func bindToViewModel()
}

public protocol SBViewForViewModel: ViewForViewModel {
    static var sbInfo: (sbID: String, viewID: String) { get }
}

public protocol BindableCellView: ViewForViewModel {
    static var CellIdentifier: String { get }
}

public protocol NibSource {
    static var NibIdentifier: String { get }
}