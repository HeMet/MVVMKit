//
//  ViewCreation.swift
//  MVVMKit
//
//  Created by Евгений Губин on 02.09.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

public protocol StoryboardSource {
    static var sbName: String { get }
    static var sbIdentifier: String { get }
}

public protocol NibSource {
    static var NibIdentifier: String { get }
}

public protocol TableViewSource {
    static var CellIdentifier: String { get }
}


extension StoryboardSource where Self: UIViewController {
    public static var sbName: String {
        return "Main"
    }
    
    public static var sbIdentifier: String {
        return "\(self)"
    }
    
    public static func new() -> Self {
        let sb = UIStoryboard(name: Self.sbName, bundle: nil)
        return sb.instantiateViewControllerWithIdentifier(self.sbIdentifier) as! Self
    }
}


extension NibSource {
    public static var NibIdentifier: String {
        return "\(self)"
    }
}

extension NibSource where Self: UIViewController {
    public static func new() -> Self {
        return Self.init(nibName: Self.NibIdentifier, bundle: nil)
    }
}

extension TableViewSource where Self: UITableViewCell {
    public static var CellIdentifier: String {
        return "\(self)"
    }
    
    public static func dequeueFrom(tableView: UITableView) -> Self? {
        return tableView.dequeueReusableCellWithIdentifier(Self.CellIdentifier) as? Self
    }
    
    public static func dequeueFrom(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Self {
        return tableView.dequeueReusableCellWithIdentifier(Self.CellIdentifier, forIndexPath: indexPath) as! Self
    }
}