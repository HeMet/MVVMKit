//
//  FeedsViewModel.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import Foundation
import MVVMKit

class FeedViewModel: ViewModel {
    var entries: [DLEntry] = []
    
    var onDisposed: ViewModelEventHandler?
    
    func loadEntries() {
        let api = DevsLifeAPI()
        api.getEntries(.Latest, page: 0, count: 5) { result in
            switch result {
            case .OK(let boxedData):
                self.entries = boxedData.value
                self.onDataChanged?()
            case .Error(let error):
                println(error)
            }
        }
    }
    
    func showEntryAtIndex(index: Int) {
        let entry = entries[index]
        GoTo.entry(sender: self)(entry)
    }
    
    func dispose() {
        onDisposed?(self)
    }
    
    var onDataChanged: (() -> ())?
}