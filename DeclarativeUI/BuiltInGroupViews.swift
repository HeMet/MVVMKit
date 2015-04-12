//
//  BuiltInGroupViews.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 12.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

extension UISplitViewController : GroupViewForViewModels {
    func bindToViewModels(viewModels: [ViewEntry]) {
        let vmd = viewEntriesToDictionary(viewModels)
        var viewControllers = [vmd["master"]!, vmd["detail"]!]
        self.viewControllers = viewControllers
    }
}

func viewEntriesToDictionary(entries: [ViewEntry]) -> Dictionary<String, UIViewController> {
    var d = Dictionary<String, UIViewController>()
    for entry in entries {
        d[entry.id] = entry.view
    }
    return d
}