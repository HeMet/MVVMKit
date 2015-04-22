//
//  GroupViewForViewModels.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 11.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

public protocol GroupViewForViewModels {
    func attachChildViews(children: OrderedDictionary<String, UIViewController>)
}
