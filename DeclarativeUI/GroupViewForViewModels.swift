//
//  GroupViewForViewModels.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 11.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

typealias ChildViewFactory = (childId: String, childVM: AnyObject) -> UIViewController

protocol GroupViewForViewModels {
    func bindToViewModels(viewModels: [AnyObject], childFactory: ChildViewFactory)
}
