//
//  DeclarativeUI.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 25.03.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

infix operator => { associativity left precedence 95 }
func => <T> (op: T, configurator: (T) -> ()) -> T {
    configurator(op)
    return op
}

func => (left : UIView, subviews: [UIView]?) {
    if let sbv = subviews {
        for v in sbv {
            left.addSubview(v)
        }
    }
}

infix operator ~> { associativity left precedence 94 }
func ~> <T> (inout left: T!, right: T) -> T {
    left = right
    return left
}