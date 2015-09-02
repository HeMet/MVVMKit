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
    var viewModel: ViewModelType! { get set }
    func bindToViewModel()
}

public protocol SBViewForViewModel: ViewForViewModel, StoryboardSource { }

public protocol BindableCellView: ViewForViewModel, TableViewSource { }