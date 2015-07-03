//
//  RangeExtension.swift
//  MVVMKit
//
//  Created by Евгений Губин on 20.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

public func newRangeOf(index: Int) -> Range<Int> {
    return Range<Int>(start: index, end: index + 1)
}

