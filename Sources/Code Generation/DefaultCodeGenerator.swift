//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/10/24.
//

import Foundation

class DefaultCodeGenerator: CodeGenerator {
    var actionNames = [String]()
    var localizedText = [String]()

    func createLabel(_ node: XMLElement) throws -> String {
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

        return output.joined()
    }
}
