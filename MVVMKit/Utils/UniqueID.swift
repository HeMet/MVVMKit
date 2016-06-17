//
//  UniqueID.swift
//  MVVMKit
//
//  Created by Евгений Губин on 30.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

// Descibes entity that can be compared by unique ID
public protocol UniqueID: Equatable {
    associatedtype IdType: Equatable
    var uniqueID: IdType { get }
}

public func ==<U0: UniqueID, U1: UniqueID>(l: U0, r: U1) -> Bool {
    guard let r = r as? U0 else { return false }
    
    return l.uniqueID == r.uniqueID
}

public extension String {
    // Returns unique string identifier each time it is called.
    public static func unique() -> String {
        return UUID().uuidString
    }
}
