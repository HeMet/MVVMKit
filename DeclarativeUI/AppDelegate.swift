//
//  AppDelegate.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 25.03.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIMVVMApplication {

    var window: UIWindow?

    var router: Router = Router()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
                      
        router.route("root", to: ViewController.self).withTransition(Transitions.root).wrapInNavigationBar()
        router.route("next", to: ViewController2.self).withTransition(Transitions.show)
        
        router.route("split", to: UISplitViewController.self).withTransition(Transitions.root)
        router.route("split.master", to: ViewController.self).wrapInNavigationBar()
        router.route("split.detail", to: ViewController2.self)
        
        router.route("tabbar", to: UITabBarController.self).withTransition(Transitions.root)
        router.route("tabbar.0", to: ViewController.self)
        router.route("tabbar.1", to: ViewController2.self)
        
        //router.navigate(self, id: "tabbar", viewModels: ["0" : SimpleViewModel(s: "master"), "1" : SimpleViewModel(s: "detail")])
        router.navigate(self, id: "split", viewModels: ["master": SimpleViewModel(s: "master"), "detail": SimpleViewModel(s: "detail")])
        //router.navigate(self, id: "root", viewModel: SimpleViewModel(s: "master"))
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

