//
//  StringExtension.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 15.04.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

// Origin: https://gist.github.com/albertbori/0faf7de867d96eb83591

import Foundation

extension String {
    func contains(s: String) -> Bool
    {
        return (self.rangeOfString(s) != nil) ? true : false
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    subscript (i: Int) -> Character
        {
        get {
            let index = advance(startIndex, i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(self.startIndex, r.endIndex - 1)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func subString(startIndex: Int, length: Int) -> String
    {
        var start = advance(self.startIndex, startIndex)
        var end = advance(self.startIndex, startIndex + length)
        return self.substringWithRange(Range<String.Index>(start: start, end: end))
    }
    
    func indexOf(target: String) -> Int
    {
        var range = self.rangeOfString(target)
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int
    {
        var startRange = advance(self.startIndex, startIndex)
        
        var range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func countOf(target: String) -> Int {
        var index = 0
        var count = 0
        do {
            index = self.indexOf(target, startIndex: index)
            if (index == -1) {
                break
            }
            count++
            index++
        } while (true)
        return count
    }
    
    func devideByIndex(index: Int) -> (String, String) {
        let left = self[Range<Int>(start: 0, end: index + 1)]
        let right = self[Range<Int>(start: index + 1, end: count(self) + 1)]
        return (left, right)
    }
}