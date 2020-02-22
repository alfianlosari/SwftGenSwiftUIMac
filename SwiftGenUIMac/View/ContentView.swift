//
//  ContentView.swift
//  macCMDTest
//
//  Created by Alfian Losari on 18/02/20.
//  Copyright © 2020 alfianlosari. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        HStack(alignment: .top, spacing: 0) {
            SidebarView()
                .frame(width: 200)
            Divider()
                .edgesIgnoringSafeArea(.top)
            MainView()
        }
        .frame(minWidth: 1200, maxHeight: 768)
    }
}

struct SidebarView: View {
    
    @EnvironmentObject var appState: AppState
    var types = SwiftGenType.allCases.map { $0 }
        
    var body: some View {
        List(selection: self.$appState.selectedType) {
            padding(.top, 16)
            
            ForEach(self.types) { type in
                HStack {
                    Text(type.rawValue)
                        .font(.headline)
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct MainView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            if appState.selectedType != nil {
                appState.selectedType!.contentView
            }
            
            ResultsView()
                .frame(minWidth: 700, maxHeight: 768)
            
        } .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ResultsView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if self.appState.isProcessing {
                ProgressView()
            } else if self.appState.command != nil {
                VStack(alignment: .trailing) {
                    MacEditorTextView(text: self.appState.command!.generateSwiftCode()!.attributedCode)
                    
                    HStack {
                        Button(action: {
                            self.appState.command!.generateSwiftCodeAndCopyToClipboard()
                        }) {
                            Text("Copy to clipboard")
                        }
                        
                        Button(action: {
                            self.openSavePanel(command: self.appState.command!)
                        }) {
                            Text("Save to file")
                        }
                    }
                    .padding(.bottom, 8)
                    .padding(.trailing, 16)
                }
                
            } else {
                Text("Select the options from the left panel to convert to generate your assets into Swift code")
            }
        }
    }
    
    func openSavePanel(command: SwiftGenCommand) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "Generated-\(command.type.rawValue).swift"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            if result == .OK {
                guard let url = savePanel.url else { return }
                DispatchQueue.global(qos: .userInitiated).async {
                    self.appState.command!.generateSwiftCodeAndSaveToFile(url: url)
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SwiftGenResult {
    var code: String
    var attributedCode: NSAttributedString
}
