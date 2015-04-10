//
//  ViewForViewModel.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 06.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

protocol ViewForViewModel {
    typealias ViewModelType
    var viewModel: ViewModelType { get }
    func bindToViewModel()
    init(viewModel: ViewModelType)
}
