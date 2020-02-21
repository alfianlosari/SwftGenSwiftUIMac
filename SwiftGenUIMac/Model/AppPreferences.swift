//
//  AppPreferences.swift
//  macCMDTest
//
//  Created by Alfian Losari on 20/02/20.
//  Copyright © 2020 alfianlosari. All rights reserved.
//

import Combine

class AppPreferences: ObservableObject {
    
    @Published var selectedType: SwiftGenType? = SwiftGenType.allCases[0] {
        didSet {
            self.command = nil
        }
    }
    
    
    @Published var command: SwiftGenCommand? = nil {
        didSet {
            
        }
    }
}
