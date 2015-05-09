//
//  BuiltInTransitions.swift
//  MVVMKit
//
//  Created by Евгений Губин on 09.05.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

// Predefined transitions
public struct Transitions {
    public static let root: Transition = { (from: UIViewController, to: UIViewController) in
        let window = UIApplication.sharedApplication().delegate?.window!
        window?.rootViewController = to
        window?.makeKeyAndVisible()
    }
    
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
