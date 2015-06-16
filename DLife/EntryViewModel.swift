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
    
    var currentEntry: DLEntry {
        didSet {
            onEntryChanged?()
        }
    }
    
    var onEntryChanged: (() -> ())?
    
    private let api = DevsLifeAPI()
    
    init(entry: DLEntry) {
        currentEntry = entry
        super.init()
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
}