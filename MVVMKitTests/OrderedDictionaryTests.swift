//
//  OrderedDictionaryTests.swift
//  MVVMKit
//
//  Created by Евгений Губин on 16.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import XCTest

class OrderedDictionaryTests: XCTestCase {

    let defaultContent = ["a": 1, "b": 2, "c": 3]
    let defaultOD: OrderedDictionary = ["a": 1, "b": 2, "c": 3]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLiteralInitialization() {
        XCTAssert(defaultOD.elementsEqual(defaultContent), "Collections should be equal.")
    }
    
    func testComparisonWithDictionary() {
        XCTAssert(defaultOD.elementsEqual(defaultContent), "Collections should be equal.")
        
        let od2: OrderedDictionary = ["a": 1, "c": 3]
        XCTAssert(!od2.elementsEqual(defaultContent), "Collections of different sizes should not be equal.")
        
        XCTAssert(!defaultOD.elementsEqual(["a": 1, "c": 3]), "Collections of different sizes should not be equal.")
    }
    
    func testIndexes() {
        XCTAssertEqual(defaultOD.startIndex, 0, "Start index should point to the beginning.")
        XCTAssertEqual(defaultOD.endIndex, 3, "End index should point past the end.")
    }
    
    func testSubscriptByIndex() {
        assert("Should return second pair.") {
            defaultOD.areElementEqual(defaultOD[1], ("b", 2))
        }
        
        assert("Pair should be inserted to position 1.") {
            defaultOD.equalsTo(["a": 1, "d": 4, "b": 2, "c": 3] , then: {
                $0.value[1] = ("d", 4)
            })
        }
        
        assert("Pair should added to the end.") {
            defaultOD.equalsTo(["a": 1, "b": 2, "c": 3, "d": 4] , then: {
                $0.value[$0.value.endIndex] = ("d", 4)
            })
        }
        
        assert("Should change value for first pair.") {
            defaultOD.equalsTo(["a": 7, "b": 2, "c": 3] , then: {
                $0.value[0] = ("a", 7)
            })
        }
        
        assert("Should move first key to the end") {
            defaultOD.equalsTo(["b": 2, "c": 3, "a": 2], then: {
                $0.value[2] = ("a", 2)
            })
        }
        
        assert("Should move last key to the beginning") {
            defaultOD.equalsTo(["c": 3, "a": 1, "b": 2], then: {
                $0.value[0] = ("c", 3)
            })
        }
        
        assert("Should move last key to the beginning") {
            defaultOD.equalsTo(["b": 2, "a": 1, "c": 3 ], then: {
                $0.value[0] = ("b", 2)
            })
        }
    }
    
    func testReplaceRange() {
        
        assert("New pairs are not inserted into right place.") {
            defaultOD.equalsTo(["a": 1, "d": 4, "e": 5, "b": 2, "c": 3] , then: {
                $0.value.replaceSubrange((1 ..< 1), with: ["d": 4, "e": 5])
            })
        }
        
        assert("Part of the dictionary should be replaced.") {
            defaultOD.equalsTo(["a": 1, "d": 4, "c": 3] , then: {
                $0.value.replaceSubrange((1 ..< 2), with: ["d": 4])
            })
        }

        assert("Part of the dictionary should be removed.") {
            defaultOD.equalsTo(["a": 1, "c": 3] , then: {
                $0.value.replaceSubrange((1 ..< 2), with: [])
            })
        }
    }
    
    func testSubscriptByKey() {
        XCTAssertEqual(defaultOD["b"], 2, "Wrong value for key.")
        
        assert("Value for second key should be changed.") {
            defaultOD.equalsTo(["a": 1, "b": 7, "c": 3], then: {
                $0.value["b"] = 7
            })
        }
        
        assert("Second pair should be removed.") {
            defaultOD.equalsTo(["a": 1, "c": 3], then: {
                $0.value["b"] = nil
            })
        }
    }
    
    func testSubscriptByRange() {
        assert("New pairs are not inserted into right place.") {
            defaultOD.equalsTo(["a": 1, "d": 4, "e": 5, "b": 2, "c": 3] , then: {
                $0.value[1..<1] = ["d": 4, "e": 5]
            })
        }
        
        assert("Part of the dictionary should be replaced.") {
            defaultOD.equalsTo(["a": 1, "d": 4, "c": 3] , then: {
                $0.value[1..<2] = ["d": 4]
            })
        }
        
        assert("Part of the dictionary should be removed.") {
            defaultOD.equalsTo(["a": 1, "c": 3] , then: {
                $0.value[1..<2] = [:]
            })
        }

        assert("Should return tail of dictionary") {
            let tail = defaultOD[1...2]
            return tail.elementsEqual(["b": 2, "c": 3])
        }
    }
    
    func assert(_ message: String, @noescape condition: () -> Bool) {
        XCTAssert(condition(), message)
    }
}

extension OrderedDictionary where KeyType: Equatable, ValueType: Equatable {

    func equalsTo(_ benchmark: DictionaryLiteral<KeyType, ValueType>, then mutator: (Box<OrderedDictionary>) -> ()) -> Bool {
        let box = Box(self)
        mutator(box)
        
        return box.value.elementsEqual(benchmark)
    }
    
    func elementsEqual<OtherSequence: Sequence where OtherSequence.Iterator.Element == Iterator.Element>(_ other: OtherSequence) -> Bool {
        return elementsEqual(other, isEquivalent: areElementEqual)
    }
    
    func elementsEqual(_ other: Dictionary<KeyType, ValueType>) -> Bool {
        return elementsEqual(other, isEquivalent: areElementEqual)
    }
    
    func areElementEqual(_ l: Element, _ r: Element) -> Bool {
        return l.0 == r.0 && l.1 == r.1
    }
}

class Box<T> {
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}
