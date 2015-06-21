//
//  EntryViewModel.swift
//  DLife
//
//  Created by Евгений Губин on 16.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import MVVMKit

class EntryViewModel: BaseViewModel {
    
    var data = ObservableArray<AnyObject>()
    
    var currentEntry: DLEntry {
        get {
            return data[0] as! DLEntry
        }
        set {
            data[0] = newValue
            onEntryChanged?()
            loadComments()
        }
    }
    
    var comments: [DLComment] {
        get {
            return data[1..<data.count].map { $0 as! DLComment }
        }
        set {
            data[1..<data.count] = newValue
        }
    }
    
    var onEntryChanged: (() -> ())?
    
    private let api = DevsLifeAPI()
    
    init(entry: DLEntry) {
        super.init()
        data = [entry]
    }
    
    func nextRandomPost() {
        api.getRandomEntry { [unowned self] result in
            switch result {
            case .OK(let box):
                self.currentEntry = box.value
            case .Error(let error):
                println(error)
            }
        }
    }
    
    func loadComments() {
        api.getComments(currentEntry.id) { [unowned self] result in
            switch result {
            case .OK(let box):
                self.comments = box.value
            case .Error(let error):
                println(error)
            }
        }
    }
}