//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/10/24.
//

import Foundation

final class CustomCodeGenerator: DefaultCodeGenerator {
    override func createLabel(_ node: XMLElement) throws -> String {
        // TOODO: Call super version instead
        guard let template = try loadTemplate(name: "Label") else { throw ConversionError.failedToLoadTemplate }

        let text = node.attribute(forName: "text")?.stringValue ?? ""
        var output = [String]()

        // If the text is empty, then just create an empty Label component
        if text.isEmpty {
            output.append(template.replacingOccurrences(of: "{{ CONTENT }}", with: text))
        } else {
            // Otherwise, create a variable to represent the localized text and use that variable name instead.
            localizedText.append(text)
            output.append(template.replacingOccurrences(of: "{{ CONTENT }}", with: text.camelCase))
        }

        // This is all Turo specific now
        if let customClass = node.attribute(forName: "customClass"), let className = customClass.stringValue, className.hasSuffix("Label") {
            output.append(".textToken(\(className.textToken))")
        }

        return output.joined()
    }
}

