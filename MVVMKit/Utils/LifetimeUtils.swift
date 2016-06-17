//
//  LifetimeUtils.swift
//  MVVMKit
//
//  Created by Евгений Губин on 14.07.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import Foundation

public func unowned<T: AnyObject, T2>(_ obj: T, _ method: (T) -> (T2) -> ()) -> (T2) -> () {
    return { [unowned obj] in
        method(obj)($0)
    }
}

public func unowned<T: NSObject, T2>(_ obj: T, _ method: (T) -> (T2) -> ()) -> (T2) -> () {
    return { [unowned(unsafe) obj] in
        method(obj)($0)
    }
}
