//
//  ViewCreation.swift
//  MVVMKit
//
//  Created by Евгений Губин on 02.09.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation

public protocol StoryboardSource {
    static var sbInfo: (sbID: String, viewID: String) { get }
}

public protocol NibSource {
    static var NibIdentifier: String { get }
}

public protocol TableViewSource {
    static var CellIdentifier: String { get }
}


extension StoryboardSource where Self: UIViewController {
    public static func new() -> Self {
        let (sbID, viewID) = Self.sbInfo
        let sb = UIStoryboard(name: sbID, bundle: nil)
        return sb.instantiateViewControllerWithIdentifier(viewID) as! Self
    }
}

extension NibSource where Self: UIViewController {
    public static func new() -> Self {
        return Self.init(nibName: Self.NibIdentifier, bundle: nil)
    }
}

extension TableViewSource where Self: UITableViewCell {
    public static func dequeueFrom(tableView: UITableView) -> Self? {
        return tableView.dequeueReusableCellWithIdentifier(Self.CellIdentifier) as? Self
    }
    
    public static func dequeueFrom(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> Self {
        return tableView.dequeueReusableCellWithIdentifier(Self.CellIdentifier, forIndexPath: indexPath) as! Self
    }
}