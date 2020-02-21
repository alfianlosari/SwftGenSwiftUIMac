//
//  Process+Extension.swift
//  macCMDTest
//
//  Created by Alfian Losari on 20/02/20.
//  Copyright © 2020 alfianlosari. All rights reserved.
//

import Foundation

extension Process {
    
    @objc static func execute(_ command: String, arguments: [String]) -> Data? {
        let task = Process()
        task.launchPath = command
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
