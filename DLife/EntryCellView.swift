//
//  EntryCellView.swift
//  DLife
//
//  Created by Евгений Губин on 12.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit
import WebImage

// TODO: Maybe it would be useful to declare ViewForViewModelHolder protocol
// to specify what viewModel should be binded to child view.

class EntryCellView: UITableViewCell, ViewForViewModel, BindableCellView, NibSource {
    static let CellIdentifier = "EntryCellView"
    static let NibIdentifier = "EntryCellView"

    @IBOutlet weak var entryView: EntryView!
    
    var viewModel: DLEntry! {
        get {
            return entryView.viewModel
        }
        set {
            entryView.viewModel = newValue
        }
    }
    
    func bindToViewModel() {
        entryView.bindToViewModel()
    }
}