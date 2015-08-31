//
//  TestTypes.swift
//  MVVMKit
//
//  Created by Евгений Губин on 30.08.15.
//  Copyright © 2015 GitHub. All rights reserved.
//

import Foundation
import MVVMKit

class FirstViewModel: ViewModelWithID {
    var uniqueID = String.unique()
}

class FirstView: UIViewController, ViewForViewModel {
    var viewModel: FirstViewModel!
    
    func bindToViewModel() {
        1 + 1
    }
}