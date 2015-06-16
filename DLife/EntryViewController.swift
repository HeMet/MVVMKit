//
//  EntryViewController.swift
//  DLife
//
//  Created by Евгений Губин on 13.06.15.
//  Copyright (c) 2015 SimbirSoft. All rights reserved.
//

import UIKit
import MVVMKit

class EntryViewController: UIViewController, SBViewForViewModel {
    static let sbInfo = (sbID: "Main", viewID: "EntryViewController")
    
    @IBOutlet weak var entryView: EntryView!
    
    var viewModel: EntryViewModel!
    
    func bindToViewModel() {
        entryView.viewModel = viewModel.currentEntry
        
        viewModel.onEntryChanged = {
            self.entryView.viewModel = self.viewModel.currentEntry
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
    }
    
    @IBAction func nextRandomPostTapped(sender: AnyObject) {
        viewModel.nextRandomPost()
    }
}
