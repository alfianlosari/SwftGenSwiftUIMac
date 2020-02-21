//
//  SwiftGen.swift
//  macCMDTest
//
//  Created by Alfian Losari on 20/02/20.
//  Copyright © 2020 alfianlosari. All rights reserved.
//

import Foundation
import SwiftUI

enum SwiftGenType: String, Identifiable, CaseIterable {
    
    var id: SwiftGenType { self }
    
    case assets = "Assets"
    case strings = "Strings"
    case colors = "Colors"
    case fonts = "Fonts"
    case ib = "Interface Builder"
    case json = "JSON"
    case yaml = "YAML"
    
    var supportedDocumentType: DocumentType {
        switch self {
        case .assets:
            return .directory
        case .strings:
            return .file
        case .colors:
            return .file
        case .fonts:
            return .directory
        case .ib:
            return .file
        case .json:
            return .file
        case .yaml:
            return .file
        }
    }
    
    var allowedFileTypes: [String] {
        switch self {
        case .assets:
            return ["xcassets"]
        case .strings:
            return ["strings"]
        case .colors:
            return ["txt", "json", "xml", "clr"]
        case .fonts:
            return ["ttf", "otf"]
        case .ib:
            return ["storyboard"]
        case .json:
            return ["json"]
        case .yaml:
            return ["yml"]
        }
    }
    
    var assetName: String {
        switch self {
        case .assets:
            return "photo"
        case .strings:
            return "photo"
        case .colors:
            return "photo"
        case .fonts:
            return "photo"
        default:
            return "photo"
        }
    }
    
    var defaultEnumName: String {
        switch self {
        case .assets:
            return XCAssetsTemplate.defaultEnumName
        case .strings:
            return StringsTemplate.defaultEnumName
        case .colors:
            return ColorsTemplate.defaultEnumName
        case .fonts:
            return FontsTemplate.defaultEnumName
        case .ib:
            return InterfaceBuildersTemplate.defaultEnumName
        case .json:
            return JSONTemplate.defaultEnumName
        case .yaml:
            return YAMLTemplate.defaultEnumName
            
        }
    }
    
    var typeValue: String {
        switch self {
        case .assets:
            return "xcassets"
        case .strings:
            return "strings"
        case .colors:
            return "colors"
        case .fonts:
            return "fonts"
        case .ib:
            return "ib"
        case .json:
            return "json"
        case .yaml:
            return "yaml"
        }
    }
}

extension SwiftGenType {
    
    var contentView: some View {
        switch self {
        case .assets:
            return AnyView(FormView<XCAssetsTemplate>(selectedTemplate: .swift4))
        case .strings:
            return AnyView(FormView<StringsTemplate>(selectedTemplate: .structuredSwift4))
        case .colors:
            return AnyView(FormView<ColorsTemplate>(selectedTemplate: .literalsSwift4))
        case .fonts:
            return AnyView(FormView<FontsTemplate>(selectedTemplate: .swift4))
        case .ib:
            return AnyView(FormView<InterfaceBuildersTemplate>(selectedTemplate: .scenesSwift4))
        case .json:
            return AnyView(FormView<JSONTemplate>(selectedTemplate: .runTimeSwift4))
        case .yaml:
            return AnyView(FormView<YAMLTemplate>(selectedTemplate: .inlineSwift4))
            
        }
    }
}
