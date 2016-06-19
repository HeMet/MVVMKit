//
//  MVVMKitTests.swift
//  MVVMKitTests
//
//  Created by Eugene Gubin on 22.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit
import XCTest
import MVVMKit

class MVVMKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRawComparisonPerfomance() {
        let f0 = FirstViewModel()
        let f1 = FirstViewModel()
        
        measure {
            for _ in 0...1000000 {
                _ = f0 == f1
            }
        }
    }
    
    func testComparisonPerfomance() {
        let f0 = FirstViewModel()
        let f1 = FirstViewModel()
        
        let any0 = AnyViewModel(viewModel: f0)
        let any1 = AnyViewModel(viewModel: f1)
        
        measure {
            for _ in 0...1000000 {
                _ = any0 == any1
            }
        }
    }
    
    func testRawBindViewModelPerfomance() {
        let v = FirstView()
        
        measure {
            for _ in 0...1000000 {
//                v.bindToViewModel()
                self.bindToViewModel(v)
            }
        }
    }
    
    func bindToViewModel<V: ViewForViewModel>(_ view: V) {
        view.bindToViewModel()
    }
    
    func testBindViewModelPerfomance() {
        let v = FirstView()
        let anyV = AnyViewForViewModel(base: v)
        
        measure {
            for _ in 0...1000000 {
                anyV.bindToViewModel()
            }
        }
    }
}
