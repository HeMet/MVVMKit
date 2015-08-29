//
//  StringExtension.swift
//  DeclarativeUI
//
//  Created by Eugene Gubin on 15.04.15.
//  Copyright (c) 2015 GitHub. All rights reserved.
//

// Origin: https://gist.github.com/albertbori/0faf7de867d96eb83591

import Foundation

// TODO: check do we realy need this extension. See String.characters property that is a CollectionType

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
            let index = startIndex.advancedBy(i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex - 1)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func subString(startIndex: Int, length: Int) -> String
    {
        let start = self.startIndex.advancedBy(startIndex)
        let end = self.startIndex.advancedBy(startIndex + length)
        return self.substringWithRange(Range<String.Index>(start: start, end: end))
    }
    
    func indexOf(target: String) -> Int
    {
        let range = self.rangeOfString(target)
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int
    {
        let startRange = self.startIndex.advancedBy(startIndex)
        
        let range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    func countOf(target: String) -> Int {
        var index = 0
        var count = 0
        repeat {
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
        let right = self[Range<Int>(start: index + 1, end: self.characters.count + 1)]
        return (left, right)
    }
}