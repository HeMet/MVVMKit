//
//  AppDelegate.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 25.03.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit
import ReactiveCocoa

extension NSTimer {
    /**
    Creates and schedules a one-time `NSTimer` instance.
    
    :param: delay The delay before execution.
    :param: handler A closure to execute after `delay`.
    
    :returns: The newly-created `NSTimer` instance.
    */
    class func schedule(#delay: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
    
    /**
    Creates and schedules a repeating `NSTimer` instance.
    
    :param: repeatInterval The interval between each execution of `handler`. Note that individual calls may be delayed; subsequent calls to `handler` will be based on the time the `NSTimer` was created.
    :param: handler A closure to execute after `delay`.
    
    :returns: The newly-created `NSTimer` instance.
    */
    class func schedule(repeatInterval interval: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIMVVMApplication {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
                      
//        router.route("root", to: ViewController.self).withTransition(Transitions.root).wrapInNavigationBar()
//        router.route("next", to: ViewController2.self).withTransition(Transitions.show)
//        
//        router.route("split", to: UISplitViewController.self).withTransition(Transitions.root)
//        router.route("split.master", to: ViewController.self).wrapInNavigationBar()
//        router.route("split.detail", to: ViewController2.self)
//        
//        router.route("tabbar", to: UITabBarController.self).withTransition(Transitions.root)
//        router.route("tabbar.0", to: ViewController.self)
//        router.route("tabbar.1", to: ViewController2.self)
        
        //router.navigate(self, id: "tabbar", viewModels: ["0" : SimpleViewModel(s: "master"), "1" : SimpleViewModel(s: "detail")])
        //router.navigate(Router.NO_MODEL, id: "split", viewModels: ["master": SimpleViewModel(s: "master"), "detail": SimpleViewModel(s: "detail")])
        //router.navigate(self, id: "root", viewModel: SimpleViewModel(s: "master"))
        
        let svm = SimpleViewModel(s: "Simple View Model")
        
        let gtr = present(!ViewController.self *> withinNavView, !ViewController2.self) *> within(SplitView.self) *> asRoot
        gtr(vm0: svm, vm1: svm)
        
        let activeProducer = SignalProducer<Bool, NoError> { sink, compositeDisposable in
            var isActive = false
            sendNext(sink, isActive)
            
            let timer = NSTimer.schedule(repeatInterval: 5) { timer in
                isActive = !isActive
                println("Throttle is active: \(!isActive)")
                sendNext(sink, isActive)
            }
            compositeDisposable.addDisposable {
                timer.invalidate()
            }
        }
        
        let producer = SignalProducer<Int, NoError> { sink, compositeDisposable in
            var i = 0
            NSTimer.schedule(repeatInterval: 0.25) { timer in
                sendNext(sink, i++)
                if (i > 100) {
                    sendCompleted(sink)
                }
            }
        }
        
        let result = producer |> throttle(interval: 1)(_while: activeProducer)
        
        result |> start(SinkOf { println($0) })
        
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

