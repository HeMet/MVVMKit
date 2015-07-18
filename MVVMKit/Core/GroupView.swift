//
//  GroupView.swift
//  MVVMKit
//
//  Created by Евгений Губин on 10.05.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

public protocol GroupView {
    typealias GroupViewType : UIViewController
    static func assemble(views: [UIViewController]) -> GroupViewType
}