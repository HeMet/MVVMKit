//
//  BuiltInTransitions.swift
//  MVVMKit
//
//  Created by Евгений Губин on 09.05.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit

// Predefined transitions
public struct Transitions {
    
    public static let show: Transition = { (from: UIViewController, to: UIViewController) in
        from.showViewController(to, sender: from);
    }
    
    public static let showDetail: Transition = { (from: UIViewController, to: UIViewController) in
        from.showDetailViewController(to, sender: from);
    }
    
    public static let showModal: Transition = { (from: UIViewController, to: UIViewController) in
        from.presentViewController(to, animated: true, completion: nil)
    }
}
