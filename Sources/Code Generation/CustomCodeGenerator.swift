//
//  CustomCodeGenerator.swift
//  
//
//  Created by Aryaman Sharda on 2/10/24.
//

import Foundation

final class CustomCodeGenerator: DefaultCodeGenerator {
    private let designSystemButtons = ["PrimaryButtonView", "OutlineButtonView", "GhostButtonView", "DestructivePrimaryButtonView", "DestructiveGhostButtonView"]

    override func createNameFromViewController(_ viewControllerNode: XMLElement) -> String {
        let viewControllerName = super.createNameFromViewController(viewControllerNode)

        let targetPrefix = "RR"
        return viewControllerName.hasPrefix(targetPrefix) ? String(viewControllerName.dropFirst(targetPrefix.count)) : viewControllerName
    }

    override func createNameFromView(_ view: XMLElement) -> String {
        let viewName = super.createNameFromView(view)

        let targetPrefix = "RR"
        return viewName.hasPrefix(targetPrefix) ? String(viewName.dropFirst(targetPrefix.count)) : viewName
    }

    override func createView(_ node: XMLElement) -> String? {
        guard let customClass = node.attribute(forName: "customClass")?.stringValue else {
            return evaluateViewElement(node)
        }

        // Treating this as a button with support for other custom classes later
        guard designSystemButtons.contains(customClass), let templateURL = Bundle.module.url(forResource: "TuroButton", withExtension: "stencil"), let template = try? String(contentsOf: templateURL) else {
            return nil
        }

        // The correct name is just the custom class with the "View" suffix dropped
        let correctComponentName = customClass.replacingOccurrences(of: "View", with: "")
        return template
            .replacingOccurrences(of: "{{ BUTTON_STYLE }}", with: correctComponentName)
    }

    override func createLabel(_ node: XMLElement) throws -> String {
        var standardOutput = [try super.createLabel(node)]

        // This is all Turo specific now
        if let customClass = node.attribute(forName: "customClass"), let className = customClass.stringValue, className.hasSuffix("Label") {
            standardOutput.append(".textToken(\(className.textToken))")
        }

        return standardOutput.joined()
    }
}

fileprivate extension String {
    var textToken: String {
        // Check if the input string ends with "Label"
        guard self.hasSuffix("Label") else {
            return self
        }

        // Remove the "Label" suffix
        let trimmedString = String(self.dropLast(5))

        // Make the first character lowercase and add a dot at the front
        let result = "." + trimmedString.prefix(1).lowercased() + trimmedString.dropFirst()
        return result
    }
}
