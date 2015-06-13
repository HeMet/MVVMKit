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
    static let next = present(!ViewController.self) *> withTransition(Transitions.show)
    static let root = present(!FeedViewController.self *> withinNavView, !ViewController2.self) *> within(SplitView.self) *> asRoot
    static let entry = present(!EntryViewController.self) *> withTransition(Transitions.showDetail)
}