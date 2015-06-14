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
    var entries = ObservableArray<DLEntry>()
    var feedToken = FeedToken(category: .Latest, pageSize: 5)
    
    var onDisposed: ViewModelEventHandler?
    
    func loadEntries() {
        let api = DevsLifeAPI()
        api.getEntries(feedToken) { result in
            switch result {
            case .OK(let boxedData):
                self.entries.extend(boxedData.value)
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