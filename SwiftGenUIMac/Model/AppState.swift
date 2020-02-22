//
//  AppappState.swift
//  macCMDTest
//
//  Created by Alfian Losari on 20/02/20.
//  Copyright © 2020 alfianlosari. All rights reserved.
//

import Combine

class AppState: ObservableObject {
    
    @Published var selectedType: SwiftGenType? = SwiftGenType.allCases[0] {
        didSet {
            self.isProcessing = false
            self.command = nil
        }
    }
    
    @Published var isProcessing: Bool = false
    @Published var command: SwiftGenCommand? = nil
}
