//
//  SwiftGen+Types.swift
//  macCMDTest
//
//  Created by Alfian Losari on 20/02/20.
//  Copyright © 2020 alfianlosari. All rights reserved.
//

import Foundation
import SwiftUI
import Splash

protocol SwiftGenCommand: class {
    
    var cachedResult: SwiftGenResult? { get set }
    
    var type: SwiftGenType { get }
    var inputURL: URL { get }
    var templateName: String { get }
    var templateParams: TemplateParams? { get }
    var parameters: [String]? { get }
    
    func generateSwiftCode() -> SwiftGenResult?
    func generateSwiftCodeAndSaveToFile(url: URL)
    func generateSwiftCodeAndCopyToClipboard()
    
}

extension SwiftGenCommand {
    
    var parameters: [String]? {
        guard let templateParams = templateParams else {
            return nil
        }
        var params = [String]()
        
        if let enumName = templateParams.enumName {
            let name = enumName.isEmpty ? type.defaultEnumName : enumName
            
            params += ["--param", "\(TemplateParameterType.enumName.rawValue)=\(name)"]
        }
        
        if let colorAliasName = templateParams.colorAliasName, !colorAliasName.isEmpty {
            params += ["--param", "\(TemplateParameterType.colorAliasName.rawValue)=\(colorAliasName)"]
        }
        
        if let colorTypeName = templateParams.colorTypeName, !colorTypeName.isEmpty {
            params += ["--param", "\(TemplateParameterType.colorTypeName.rawValue)=\(colorTypeName)"]
        }
        
        if let imageTypeName = templateParams.imageTypeName, !imageTypeName.isEmpty {
            params += ["--param", "\(TemplateParameterType.imageTypeName.rawValue)=\(imageTypeName)"]
        }
        
        if let imageAliasName = templateParams.imageAliasName, !imageAliasName.isEmpty {
            params += ["--param", "\(TemplateParameterType.imageAliasName.rawValue)=\(imageAliasName)"]
        }
        
        if let sceneEnumName = templateParams.sceneEnumName, !sceneEnumName.isEmpty {
            params += ["--param", "\(TemplateParameterType.sceneEnumName.rawValue)=\(sceneEnumName)"]
        }
        
        if let segueEnumName = templateParams.segueEnumName, !segueEnumName.isEmpty {
            params += ["--param", "\(TemplateParameterType.segueEnumName.rawValue)=\(segueEnumName)"]
        }
        
        if let noAllValues = templateParams.noAllValues, noAllValues {
            params += ["--param", TemplateParameterType.noAllValues.rawValue]
        }
        
        if let preservePath = templateParams.preservePath, preservePath {
            params += ["--param", TemplateParameterType.preservePath.rawValue]
        }
        
        if let module = templateParams.module, module {
            params += ["--param", TemplateParameterType.module.rawValue]
        }
        
        if let ignoreTargetModule = templateParams.ignoreTargetModule, ignoreTargetModule {
            params += ["--param", TemplateParameterType.ignoreTargetModule.rawValue]
        }
        
        if let publicAccess = templateParams.publicAccess, publicAccess {
            params += ["--param", TemplateParameterType.publicAccess.rawValue]
        }
        
        if let noComments = templateParams.noComments, noComments {
            params += ["--param", TemplateParameterType.noComments.rawValue]
        }
        
        return params
    }
    
    
    private func executeCommand(parameters: [String]) -> String? {
        let swiftGenPath = "/usr/local/bin/swiftgen"
        
        var arguments: [String] = [self.type.typeValue, inputURL.path, "--templateName", templateName]
        arguments += parameters

        if let data = Process.execute(swiftGenPath, arguments: arguments) {
            let string = String(data: data, encoding: .utf8)
            return string
        } else {
            return nil
        }
    }
    
    func generateSwiftCode() -> SwiftGenResult? {
        if let cachedResult = self.cachedResult {
            return cachedResult
        }
        
        guard let result = executeCommand(parameters: self.parameters ?? []) else {
            return SwiftGenResult(code: "", attributedCode: NSAttributedString(string: ""))
        }
                
        let highlighter = SyntaxHighlighter(format: AttributedStringOutputFormat(theme: Theme.midnight(withFont: Splash.Font.init(size: 20))))
        let attrString = highlighter.highlight(result)
        let swiftGenResult = SwiftGenResult(code: result, attributedCode: attrString)
        cachedResult = swiftGenResult
        return swiftGenResult
       
    }
    
    func generateSwiftCodeAndSaveToFile(url: URL) {
        var parameters = self.parameters ?? []
        parameters += ["--output", url.path]
        
        _ = executeCommand(parameters: parameters)
    }
    
    func generateSwiftCodeAndCopyToClipboard() {
        let text: String
        if let cachedText = cachedResult?.code {
            text = cachedText
        } else if let _text = executeCommand(parameters: parameters ?? []) {
            text = _text
        } else {
            return
        }
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([text as NSString])
    }
    
}

class SwiftGenConcreteCommand: SwiftGenCommand {

    
    var type: SwiftGenType
    var inputURL: URL {
        didSet { cachedResult = nil }
    }
    var templateName: String
    var templateParams: TemplateParams?
    
    var cachedResult: SwiftGenResult? = nil
    
    init(type: SwiftGenType, inputURL: URL, templateName: String, templateParams: TemplateParams?, cachedResult: SwiftGenResult? = nil) {
        self.type = type
        self.inputURL = inputURL
        self.templateName = templateName
        self.templateParams = templateParams
        self.cachedResult = cachedResult
    }
    
}


enum AccessModifier: String, CaseIterable {
    case `public`
    case `internal`
}

struct TemplateParams {
    var enumName: String?
    var colorAliasName: String?
    var colorTypeName: String?
    var imageTypeName: String?
    var imageAliasName: String?
    var sceneEnumName: String?
    var segueEnumName: String?
    var module: Bool?
    var noAllValues: Bool?
    var preservePath: Bool?
    var ignoreTargetModule: Bool?
    var publicAccess: Bool?
    var noComments: Bool?
}

protocol SelectedAssetTemplate: Hashable  {
    
    var rawValue: String { get }
    var parameters: [TemplateParameterType] { get }
    static var allCases: [Self] { get }
    
    static var type: SwiftGenType { get }
    static var defaultEnumName: String { get }

}


enum XCAssetsTemplate: String, CaseIterable, SelectedAssetTemplate {
    case swift2
    case swift3
    case swift4
    
    static var defaultEnumName: String { "Asset" }
    static var type: SwiftGenType { SwiftGenType.assets }
    
    var parameters: [(TemplateParameterType)] {
        switch  self {
        case .swift2:
            return  [.enumName, .imageAliasName, .colorTypeName, .imageTypeName, .noAllValues, .publicAccess]
        case .swift3, .swift4:
            return  [.enumName, .colorAliasName, .imageAliasName, .colorTypeName, .imageTypeName, .noAllValues, .publicAccess]
        }
    }
}


enum ColorsTemplate: String, CaseIterable, SelectedAssetTemplate {
    case literalsSwift3 = "literals-swift3"
    case literalsSwift4 = "literals-swift4"
    case swift2
    case swift3
    case swift4
    
    static var defaultEnumName: String { "ColorName" }
    static var type: SwiftGenType { SwiftGenType.colors }
    
    
    var parameters: [(TemplateParameterType)] {
        switch self {
        case .literalsSwift3, .literalsSwift4:
            return [
                .enumName, .publicAccess
            ]
            
        case .swift2, .swift3, .swift4:
            return [
                .enumName, .colorAliasName, .publicAccess
            ]
        }
    }
}

enum FontsTemplate: String, CaseIterable, SelectedAssetTemplate {
    
    static var defaultEnumName: String { "FontFamily"}
    static var type: SwiftGenType { SwiftGenType.fonts }

    case swift2
    case swift3
    case swift4
    
    var parameters: [(TemplateParameterType)] {
        [.enumName, .preservePath, .publicAccess]
    }
}

enum InterfaceBuildersTemplate: String, CaseIterable, SelectedAssetTemplate {
    
    static var defaultEnumName: String { "" }
    static var type: SwiftGenType { SwiftGenType.ib }

    case scenesSwift4 = "scenes-swift4"
    case seguesSwift4 = "segues-swift4"
    case scenesSwift3 = "scenes-swift3"
    case seguesSwift3 = "segues-swift3"
    
    
    var parameters: [(TemplateParameterType)] {
        [
            .sceneEnumName, .segueEnumName, .module, .ignoreTargetModule, .publicAccess
        ]
    }
}

enum StringsTemplate: String, CaseIterable, SelectedAssetTemplate {
    
    static var defaultEnumName: String { "L10n" }
    static var type: SwiftGenType { SwiftGenType.strings }
    
    case flatSwift2 = "flat-swift2"
    case flatSwift3 = "flat-swift3"
    case flatSwift4 = "flat-swift4"
    case structuredSwift2 = "structured-swift2"
    case structuredSwift3 = "structured-swift3"
    case structuredSwift4 = "structured-swift4"
    
    var parameters: [(TemplateParameterType)] {
        [
            .enumName, .noComments, .publicAccess
        ]
    }
    
}

enum JSONTemplate: String, CaseIterable, SelectedAssetTemplate {
    
    static var defaultEnumName: String { "JSONFiles" }
    static var type: SwiftGenType { SwiftGenType.json }
    
    case runTimeSwift4 = "runtime-swift4"
    case inlineSwift4 = "inline-swift4"
    case inlineSwift3 = "inline-swift3"
    case runTimeSwift3 = "runtime-swift3"
    
    var parameters: [(TemplateParameterType)] {
        [
            .enumName, .publicAccess
        ]
    }
    
}

enum YAMLTemplate: String, CaseIterable, SelectedAssetTemplate {
    
    static var defaultEnumName: String { "YAMLFiles" }
    static var type: SwiftGenType { SwiftGenType.yaml }
    
    case inlineSwift4 = "inline-swift4"
    case inlineSwift3 = "inline-swift3"
    
    var parameters: [(TemplateParameterType)] {
        [
            .enumName, .publicAccess
        ]
    }
    
}


enum TemplateParameterType: String, Identifiable, CaseIterable {
    
    var id: TemplateParameterType { self }
    case enumName
    case colorAliasName
    case imageAliasName
    case colorTypeName
    case imageTypeName
    case sceneEnumName
    case segueEnumName
    case noAllValues
    case preservePath
    case module
    case ignoreTargetModule
    case publicAccess
    case noComments
    
    var defaultValue: String? {
        switch self {
        case .colorAliasName:
            return "Color"
        case .imageAliasName:
            return "Image"
        case .colorTypeName:
            return "ColorAsset"
        case .imageTypeName:
            return "ImageAsset"
        case .sceneEnumName:
            return "StoryboardScene"
        case .segueEnumName:
            return "StoryboardSegue"
        case .enumName,
             .preservePath,
             .module,
             .ignoreTargetModule,
             .publicAccess,
             .noAllValues,
             .noComments:
            return nil
        }
    }
    
    var label: String {
        switch self {
        case .colorAliasName:
            return "Color alias name"
        case .imageAliasName:
            return "Image alias name"
        case .colorTypeName:
            return "Color type name"
        case .imageTypeName:
            return "Image type name"
        case .sceneEnumName:
            return "Scene enum name"
        case .segueEnumName:
            return "Segue enum name"
        case .enumName:
            return "Enum class name"
        case .preservePath:
            return "Preserve path"
        case .module:
            return "Module"
        case .ignoreTargetModule:
            return "Ignore target module"
        case .publicAccess:
            return "Public access"
        case .noAllValues:
            return "No all values"
        case .noComments:
            return "No comments"
      
        }
    }
    
    
    static var stringFieldCases: [TemplateParameterType] {
        [
            .enumName,
            .colorAliasName,
            .imageAliasName,
            .colorTypeName,
            .imageTypeName,
            .sceneEnumName,
            .segueEnumName
        ]
    }
    
    static var boolFieldCases: [TemplateParameterType] {
        [
            .preservePath,
            .module,
            .ignoreTargetModule,
            .publicAccess,
            .noAllValues,
            .noComments
        ]
    }
    
    
}

extension TemplateParameterType {
    func textFieldFormView(binding: Binding<String>) -> some View {
         VStack(alignment: .leading, spacing: 8) {
            Text(self.label)
            TextField("", text: binding)
        }

    }
    
    func toggleFormView(binding: Binding<Bool>) -> some View {
        Toggle(self.label, isOn: binding)

    }
}
