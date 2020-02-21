//
//  FileSelectView.swift
//  macCMDTest
//
//  Created by Alfian Losari on 20/02/20.
//  Copyright © 2020 alfianlosari. All rights reserved.
//

import SwiftUI
import Cocoa

struct FileSelectView: View {
        
    var documentType = DocumentType.file
    var allowedFileTypes: [String]
    var selectedURL: (URL) -> ()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Input Resource \(documentType.rawValue)")
                .font(.headline)
            Button(action: {
                self.open()
            }) {
                Text("Select \(documentType.rawValue)")
            }
            
            Text("Supported extension: \(allowedFileTypes.joined(separator: ", "))")
                .font(.caption)
        }
    }
    
    func open() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = self.documentType == .file
        panel.canChooseDirectories = self.documentType == .directory
        
        panel.allowedFileTypes = allowedFileTypes
        panel.canChooseFiles = true
        panel.begin { (result) in
            switch result {
            case .OK:
                guard let url = panel.urls.first else { return }
                self.selectedURL(url)
    
            default:
                print("failed to get file location")
            }
        }
    }
}

enum DocumentType: String {
    case file
    case directory
}
