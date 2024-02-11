//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/10/24.
//

import Foundation

protocol CodeGenerator {
    var actionNames: [String] { get set }
    var localizedText: [String]  { get set }


    func evaluateViewController(_ viewController: XMLElement) -> String?
    func evaluateSubviews(_ containerView: XMLElement) -> String?
    func evaluateViewElement(_ node: XMLNode) -> String
    func loadTemplate(name: String) throws -> String?

    func createLabel(_ node: XMLElement) throws -> String
    func createScrollView(_ node: XMLElement) throws -> String
    func createImage(_ node: XMLElement) throws -> String
    func createView(_ node: XMLElement) -> String
    func createSubviews(_ node: XMLElement) throws -> String
    func createTableView(_ node: XMLElement) throws -> String
    func createTableViewCellContentView(_ node: XMLElement) throws -> String
    func createTextField(_ node: XMLElement) throws -> String
    func createButton(_ node: XMLElement) -> String
    func createLocalizedTextExtension(className: String) throws -> String
}

extension CodeGenerator {
    func loadTemplate(name: String) throws -> String? {
        guard let templateURL = Bundle.module.url(forResource: name, withExtension: "stencil"), let template = try? String(contentsOf: templateURL) else {
            print("Failed to load template file.")
            return nil
        }

        return template
    }

    func evaluateViewController(_ viewController: XMLElement) -> String? {
        guard let containerView = viewController.elements(forName: "view").first else {
            print("Unable to find view in viewController element. Please check that the storyboard is valid.")
            return nil
        }

        return evaluateSubviews(containerView)
    }

    func evaluateSubviews(_ containerView: XMLElement) -> String? {
        guard let templateURL = Bundle.module.url(forResource: "Body", withExtension: "stencil"), let template = try? String(contentsOf: templateURL) else {
            print("Failed to load template file.")
            return nil
        }

        let subviews = containerView.elements(forName: "subviews")
        let output = subviews.reduce("") { result, subview in
            let content = evaluateViewElement(subview)
            return result + template.replacingOccurrences(of: "{{ CONTENT }}", with: content)
        }

        return output
    }

    func evaluateViewElement(_ node: XMLNode) -> String {
        guard node.childCount != 0 else {
            // This node is a leaf node
            return node.name ?? "" + "\n"
        }

        return (node.children ?? []).compactMap { child in
            guard let name = child.name, let type = SupportedElements(rawValue: name), let element = child as? XMLElement else {
                return nil
            }

            do {
                switch type {
                case .label:
                    return try createLabel(element)
                case .scrollView:
                    return try createScrollView(element)
                case .imageView:
                    return try createImage(element)
                case .stackView:
                    return try createStackView(element)
                case .view:
                    return createView(element)
                case .subviews:
                    return try createSubviews(element)
                case .textField:
                    return try createTextField(element)
                case .button:
                    return createButton(element)
                case .tableView:
                    return try createTableView(element)
                case .tableViewCellContentView:
                    return try createTableViewCellContentView(element)
                }
            } catch {
                print(error)
                return nil
            }
        }.joined(separator: "\n")
    }

    func createScrollView(_ node: XMLElement) throws -> String {
        guard let template = try loadTemplate(name: "ScrollView") else { throw ConversionError.failedToLoadTemplate }
        return template.replacingOccurrences(of: "{{ CONTENT }}", with: evaluateViewElement(node))
    }

    func createImage(_ node: XMLElement) throws -> String {
        guard let template = try loadTemplate(name: "Image") else { throw ConversionError.failedToLoadTemplate }

        var output = [String]()

        let imageName = node.attribute(forName: "image")?.stringValue ?? ""
        output.append(template.replacingOccurrences(of: "{{ CONTENT }}", with: imageName.camelCase))

        if let frame = node.children?.first(where: { $0.name == "rect" }) as? XMLElement,
           let width = frame.attribute(forName: "width")?.stringValue,
           let height = frame.attribute(forName: "height")?.stringValue {
            output.append(".frame(width: \(width), height: \(height))")
        }

        //        if let contentMode = node.attribute(forName: "contentMode")?.stringValue {
        //            output.append( ".aspectRatio(contentMode: .\(contentMode))")
        //        }

        return output.joined()
    }

    func createStackView(_ node: XMLElement) throws -> String {
        guard let vStackTemplate = try loadTemplate(name: "VStack"),
                let hStackTemplate = try loadTemplate(name: "HStack") else {
            throw ConversionError.failedToLoadTemplate
        }

        var template: String = hStackTemplate

        // Defaults to HStack if unspecified
        if let axisElement = node.attribute(forName: "axis"), let axisValue = axisElement.stringValue {
            if axisValue == "vertical" {
                template = vStackTemplate
            } else if axisValue == "horizontal" {
                template = hStackTemplate
            }
        }

        // Set to default spacing since we don't want any StackView to be without a space specified
        let defaultSpacing: Int = 8
        let spacing = String(node.attribute(forName: "spacing")?.stringValue?.nearestPowerOf2 ?? defaultSpacing)

        return template
            .replacingOccurrences(of: "{{ SPACE_AMOUNT }}", with: spacing)
            .replacingOccurrences(of: "{{ CONTENT }}", with: evaluateViewElement(node))
    }

    func createView(_ node: XMLElement) -> String {
        guard let customClass = node.attribute(forName: "customClass")?.stringValue else {
            return evaluateViewElement(node)
        }

        print("An unknown type was detected. To add support, please add support for \(customClass) to the known types.")
        return "// \(customClass)"
    }

    func createSubviews(_ node: XMLElement) throws -> String {
        evaluateViewElement(node)
    }

    func createTableView(_ node: XMLElement) throws -> String {
        guard let tableViewTemplate = try loadTemplate(name: "TableView") else {
            throw ConversionError.failedToLoadTemplate
        }

        let prototypes = node.children?.first(where: { $0.name == "prototypes" })
        guard let tableViewCells = prototypes?.children?.filter({ $0.name == "tableViewCell" }) else { return "" }

        let cells = tableViewCells.compactMap { cell in
            return evaluateViewElement(cell)
        }.joined(separator: "\n").trimmingCharacters(in: .whitespaces)


        return tableViewTemplate.replacingOccurrences(of: "{{ CONTENT }}", with: cells)
    }

    func createTableViewCellContentView(_ node: XMLElement) throws -> String {
        guard let cellContentView = try loadTemplate(name: "TableViewCellContentView") else {
            throw ConversionError.failedToLoadTemplate
        }

        return cellContentView.replacingOccurrences(of: "{{ CONTENT }}", with: evaluateViewElement(node))
    }

    func createTextField(_ node: XMLElement) throws -> String {
        guard let textFieldTemplate = try loadTemplate(name: "TextField") else {
            throw ConversionError.failedToLoadTemplate
        }

        let placeholderText = node.attribute(forName: "placeholder")?.stringValue
        if let placeholderText {
//            localizedText.append(placeholderText) // localizedText: inout [String]) and then have default adn turo create their own arrays
        }

        var output = [
            textFieldTemplate
                .replacingOccurrences(of: "{{ BINDING }}", with: placeholderText?.camelCase ?? "textInput")
                .replacingOccurrences(of: "{{ PLACEHOLDER }}", with: placeholderText ?? "")
        ]

        if let textColorElement = node.attribute(forName: "textColor"), let textColor = textColorElement.stringValue {
            output.append(".foregroundColor(Color(\(textColor)))")
        }

        // Process textInputTraits
        if let textInputTraitsAttributes = node.children?.first(where: { $0.name == "textInputTraits"}) as? XMLElement {
            // Adds `autocapitalizationType` if the styling is something other than sentences
            if let autocapitalizationTypeNode = textInputTraitsAttributes.attribute(forName: "autocapitalizationType"),
               let autocapitalizationType = autocapitalizationTypeNode.stringValue,
               autocapitalizationType != "sentences" {
                output.append(".textInputAutocapitalization(.\(autocapitalizationType))")
            }

            // Adds `autocorrectionType` if the settings is something other than `default`
            if let autocorrectionTypeNode = textInputTraitsAttributes.attribute(forName: "autocorrectionType"),
               let autocorrectionType = autocorrectionTypeNode.stringValue,
               autocorrectionType != "default" {

                if autocorrectionType == "yes" {
                    output.append(".disableAutocorrection(false)")
                } else if autocorrectionType == "no" {
                    output.append(".disableAutocorrection(true)")
                }
            }
        }

        return output.joined()
    }

    func createButton(_ node: XMLElement) -> String {
        "Button"
    }

    func createLocalizedTextExtension(className: String) throws -> String {
        guard let localizedTextExtensionTemplate = try loadTemplate(name: "LocalizedTextContainer"),
              let localizedTextTemplate = try loadTemplate(name: "LocalizedText") else {
            throw ConversionError.failedToLoadTemplate
        }

        guard !localizedText.isEmpty else { return "" }

        let localizedStringOutput = localizedText.map { localizedItem in
            let result = localizedTextTemplate
                .replacingOccurrences(of: "{{ VARIABLE_NAME }}", with: localizedItem.camelCase)
                .replacingOccurrences(of: "{{ KEY }}", with: localizedItem.snakeCase)
                .replacingOccurrences(of: "{{ VALUE }}", with: localizedItem)
            return result
        }.joined(separator: "\n").trimmingCharacters(in: .whitespaces)

        return localizedTextExtensionTemplate
            .replacingOccurrences(of: "{{ CONTENT }}", with: localizedStringOutput)
            .replacingOccurrences(of: "{{ CLASS_NAME }}", with: className)
//            .replacingOccurrences(of: "{{ PLACEHOLDER }}", with: placeholder)

    }
}

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

        // This is all Turo specific now
        if let customClass = node.attribute(forName: "customClass"), let className = customClass.stringValue, className.hasSuffix("Label") {
            output.append(".textToken(\(className.textToken))")
        }

        return output.joined()
    }
}

class CustomCodeGenerator: CodeGenerator {
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
//            localizedText.append(text)
            output.append(template.replacingOccurrences(of: "{{ CONTENT }}", with: text.camelCase))
        }

        // This is all Turo specific now
        if let customClass = node.attribute(forName: "customClass"), let className = customClass.stringValue, className.hasSuffix("Label") {
            output.append(".textToken(\(className.textToken))")
        }

        return output.joined()
    }
}
