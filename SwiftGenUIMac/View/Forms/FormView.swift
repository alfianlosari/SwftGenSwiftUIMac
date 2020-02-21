//
//  FormView.swift
//  macCMDTest
//
//  Created by Alfian Losari on 20/02/20.
//  Copyright © 2020 alfianlosari. All rights reserved.
//

import SwiftUI
import Splash

struct FormView<S: SelectedAssetTemplate>: View {
    
    @EnvironmentObject var preferences: AppPreferences
    
    var templates: [S] { S.allCases }
    
    @State var selectedTemplate: S
    @State var selectedURL: URL?
    @State var enumClassName: String = S.defaultEnumName
    @State var colorAliasName: String = TemplateParameterType.colorAliasName.defaultValue ?? ""
    @State var imageTypeName: String = TemplateParameterType.imageTypeName.defaultValue ?? ""
    @State var imageAliasName: String = TemplateParameterType.imageAliasName.defaultValue ?? ""
    @State var colorTypeName: String = TemplateParameterType.colorTypeName.defaultValue ?? ""
    @State var sceneEnumName: String = TemplateParameterType.sceneEnumName.defaultValue ?? ""
    @State var segueEnumName: String = TemplateParameterType.segueEnumName.defaultValue ?? ""
    
    @State var preservePath: Bool = false
    @State var publicAccess: Bool = false
    @State var noAllValues: Bool = false
    @State var module: Bool = false
    @State var ignoreTargetModule: Bool = false
    @State var noComments: Bool = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            FileSelectView(
                documentType: S.type.supportedDocumentType,
                allowedFileTypes: S.type.allowedFileTypes
            ) { url in
                self.selectedURL = url
            }
            
            Divider()
            
            if self.selectedURL != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected directory")
                        .font(.headline)
                    Text(self.selectedURL!.path)
                        .lineLimit(5)
                        .font(.caption)
                }
                
                Divider()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Template & Parameters")
                    .font(.headline)
                
                Picker(selection: self.$selectedTemplate, label: Text("Template")) {
                    ForEach(self.templates, id: \.self) { template in
                        Text(template.rawValue).tag(template)
                    }
                }
                
                TemplateTextFieldFormView(
                    defaultEnumName: S.defaultEnumName,
                    selectedTemplateParameters: self.selectedTemplate.parameters,
                    enumClassName: self.$enumClassName,
                    colorAliasName: self.$colorAliasName,
                    imageTypeName: self.$imageTypeName,
                    imageAliasName: self.$imageAliasName,
                    colorTypeName: self.$colorTypeName,
                    sceneEnumName: self.$sceneEnumName,
                    segueEnumName: self.$segueEnumName
                )
                
                TemplateToggleFormView(
                    selectedTemplateParameters: self.selectedTemplate.parameters, preservePath: self.$preservePath, publicAccess: self.$publicAccess, noAllValues: self.$noAllValues, module: self.$module, ignoreTargetModule: self.$ignoreTargetModule, noComments: self.$noComments
                )
            }
            
            Divider()
            
            Button(action: {
                self.generateSwiftGen()
            }) {
                Text("Generate Swift Code")
            }.disabled(self.selectedURL == nil)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(width: 300, height: 768)
        
    }
    
    func generateSwiftGen() {
        guard let inputURL = self.selectedURL
            else {
                return
        }
        
        let templateParams = TemplateParams(
            enumName: self.enumClassName,
            colorAliasName: self.colorAliasName,
            colorTypeName: self.colorTypeName,
            imageTypeName: self.imageTypeName,
            imageAliasName: self.imageAliasName,
            sceneEnumName: self.sceneEnumName,
            segueEnumName: self.segueEnumName,
            module: self.module,
            noAllValues: self.noAllValues,
            preservePath: self.preservePath,
            ignoreTargetModule: self.ignoreTargetModule,
            publicAccess: self.publicAccess,
            noComments: self.noComments
        )
        
        let swiftGenCommand = SwiftGenConcreteCommand(
            type: S.type,
            inputURL: inputURL,
            templateName: self.selectedTemplate.rawValue,
            templateParams: templateParams)
        
        self.preferences.command = swiftGenCommand
    }
    
}

struct TemplateToggleFormView: View {
        
    var selectedTemplateParameters: [TemplateParameterType]
    
    @Binding var preservePath: Bool
    @Binding var publicAccess: Bool
    @Binding var noAllValues: Bool
    @Binding var module: Bool
    @Binding var ignoreTargetModule: Bool
    @Binding var noComments: Bool
    
    func binding(for parameter: TemplateParameterType) -> Binding<Bool> {
        switch parameter {
        case .preservePath:
            return self.$preservePath
        case .module:
            return self.$module
        case .ignoreTargetModule:
            return self.$ignoreTargetModule
        case .publicAccess:
            return self.$publicAccess
        case .noAllValues:
            return self.$noAllValues
        case .noComments:
            return self.$noComments
        default:
            fatalError()
        }
    }
    
    var body: some View {
        ForEach(TemplateParameterType.boolFieldCases) { parameter in
            if self.selectedTemplateParameters.firstIndex(of: parameter) != nil {
                parameter.toggleFormView(binding: self.binding(for: parameter))
            }
        }
    }
}


struct TemplateTextFieldFormView: View {
    
    var defaultEnumName: String
    var selectedTemplateParameters: [TemplateParameterType]
    
    @Binding var enumClassName: String
    @Binding var colorAliasName: String
    @Binding var imageTypeName: String
    @Binding var imageAliasName: String
    @Binding var colorTypeName: String
    @Binding var sceneEnumName: String
    @Binding var segueEnumName: String
    
    func binding(for parameter: TemplateParameterType) -> Binding<String> {
        switch parameter {
        case .enumName:
            return self.$enumClassName
        case .colorAliasName:
            return self.$colorAliasName
        case .imageAliasName:
            return self.$imageAliasName
        case .colorTypeName:
            return self.$colorTypeName
        case .imageTypeName:
            return self.$imageTypeName
        case .sceneEnumName:
            return self.$sceneEnumName
        case .segueEnumName:
            return self.$segueEnumName
        default:
            fatalError()
        }
    }
    
    var body: some View {
        ForEach(TemplateParameterType.stringFieldCases) { parameter in
            if self.selectedTemplateParameters.firstIndex(of: parameter) != nil {
                parameter.textFieldFormView(binding: self.binding(for: parameter))
            }
        }
    }
    
}
