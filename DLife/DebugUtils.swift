//
//  DebugUtils.swift
//  DLife
//
//  Created by Евгений Губин on 16.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import WebImage

extension SDImageCacheType: Printable {
    public var description: String {
        switch (self) {
        case .None: return "None"
        case .Disk: return "Disk"
        case .Memory: return "Memory"
        }
    }
}