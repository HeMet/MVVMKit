//
//  GoTo.swift
//  DeclarativeUI
//
//  Created by Евгений Губин on 10.05.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

struct GoTo {
    static let next = present(!ViewController.self).withTransition(Transitions.show)
    static let root = present(!FeedViewController.self).withinNavView().asRoot()
    static let entry = present(!EntryViewController.self).withTransition(Transitions.show)

    static let root2 = present(!Test2ViewController.self).asRoot()
    static let popover = present(!TestViewController.self).asPopoverOn(Test2ViewController.self) { pvc, popover in
        pvc.preferredContentSize = CGSize(width: 200, height: 300)
        popover.sourceView = pvc.btnPopober
        popover.sourceRect = pvc.btnPopober.bounds
    }
}