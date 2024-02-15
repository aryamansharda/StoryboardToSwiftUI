//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/10/24.
//

import Foundation

final class CustomCodeGenerator: DefaultCodeGenerator {
    override func createView(_ node: XMLElement) -> String {
        let output = super.createView(node)

        if output.contains("Plain") || output.contains("Ghost") {
            print("This is a Pedal component")
        }

        return output
    }

    override func createLabel(_ node: XMLElement) throws -> String {
        // TOODO: Call super version instead
        var standardOutput = [try super.createLabel(node)]

        // This is all Turo specific now
        if let customClass = node.attribute(forName: "customClass"), let className = customClass.stringValue, className.hasSuffix("Label") {
            standardOutput.append(".textToken(\(className.textToken))")
        }

        return standardOutput.joined()
    }
}

