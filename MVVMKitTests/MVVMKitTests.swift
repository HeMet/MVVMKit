//
//  MVVMKitTests.swift
//  MVVMKitTests
//
//  Created by Eugene Gubin on 22.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

import UIKit
import XCTest

class MVVMKitTests: XCTestCase {
    
    var observableArray: ObservableArray<Int> = [1, 2, 3]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        observableArray.onDidChangeItems.register("123") { ctx, args in
            print("change \(args.debugDescription)")
        }
        observableArray.onDidInsertItems.register("123") { ctx, args in
            print("insert \(args.debugDescription)")
        }
        observableArray.onDidRemoveItems.register("123") { ctx, args in
            print("remove \(args.debugDescription)")
        }
        observableArray.onBatchUpdate.register("123") { ctx, phase in
            print("update \(phase)")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        observableArray[2] = 5
        observableArray.removeLast()
        observableArray[1...1] = [4, 5, 7]
    }
    
    func testExample2() {
        let od: ObservableOrderedDictionary<String, Int> = ["a" : 4, "b" : 5, "c" : 6]
        od[2] = ("b", 7)
        
        od["b"] = 8
        print(od)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}