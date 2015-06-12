//
//  ViewForViewModel.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 06.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public protocol ViewForViewModel {
    typealias ViewModelType
    var viewModel: ViewModelType! { get set }
    func bindToViewModel()
    init()
}

public protocol SBViewForViewModel: ViewForViewModel {
    static var sbID : String { get }
    static var viewID: String { get }
}