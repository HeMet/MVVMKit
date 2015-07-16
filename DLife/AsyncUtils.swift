//
//  AsyncUtils.swift
//  DLife
//
//  Created by Евгений Губин on 08.07.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation

func async(qos: qos_class_t, callback: () -> ()) {
    let queue = dispatch_get_global_queue(qos, 0)
    dispatch_async(queue, callback)
}

func backgroundTask(callback: () -> ()) {
    async(QOS_CLASS_BACKGROUND, callback)
}

func uiTask(callack: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), callack)
}