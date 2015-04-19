//
//  ViewController.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 25.03.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ViewController: UIViewController, ViewForViewModel {

    let viewModel : SimpleViewModel!
    
    var subviewHook : UILabel!
    var doButton: UIButton!
    
    required init(viewModel: SimpleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.data
    }

    required init(coder aDecoder: NSCoder) {
        viewModel = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        view = UIView() => {
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            $0.backgroundColor = UIColor.redColor()
            
            $0 => [
                self.subviewHook ~> UILabel() => {
                    $0.backgroundColor = UIColor.greenColor()
                    $0.frame = CGRect(x: 5, y: 100, width: 60, height: 30)
                    $0.text = self.viewModel.data
                },
                self.doButton ~> UIButton() => {
                    $0.frame = CGRect(x: 40, y: 100, width: 60, height: 30)
                    $0.setTitle("Do!", forState: UIControlState.Normal)
                }
            ]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
    
    var ca: CocoaAction!
    var d: Disposable?
    func bindToViewModel() {
        DynamicProperty(object: self.subviewHook, keyPath: "text") <~ viewModel.value.producer |> map { "\($0)" }
        
        ca = CocoaAction(viewModel.increment)
        doButton.addTarget(ca, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
        
        viewModel.didBecomeActiveSignal |> start(error: nil, completed: nil, interrupted: nil, next: { x in println("Become active!") })
        
        /*timer(NSTimeInterval(1), onScheduler: QueueScheduler()).startWithSignal { signal, disposable in
            let forwarded = self.viewModel.forwardSignalWhileActive(signal)
            forwarded.observe(error: nil, completed: nil, interrupted: nil) { date in
                println("\(date)")
            }
        }*/
        
        
        d = viewModel.forwardSignalWhileActive(timer(NSTimeInterval(1), onScheduler: QueueScheduler())).start(error: nil, completed: nil, interrupted: nil) { date in
            println("\(date)")
        }
    }
    
    deinit {
        println("deinit")
    }
    
    override func viewDidAppear(animated: Bool) {
        viewModel.active.value = true
        println("d \(d?.disposed)")
    }
    
    override func viewDidDisappear(animated: Bool) {
        viewModel.active.value = false
    }
}