//
//  DefaultCodeGenerator.swift
//
//
//  Created by Aryaman Sharda on 2/10/24.
//

import Foundation

class DefaultCodeGenerator {
    var localizedText = [String]()

    func generate(root: XMLElement) {
        guard let contentType = determineStoryboardContentType(root: root) else {
            print("Unable to determine .storyboard file contents.")
            return
        }

        switch contentType {
        case .viewControllers(let viewControllers):
            let viewController = promptUserForSelection(items: viewControllers) { viewController in
                createNameFromViewController(viewController)
            }

            guard let viewController else {
                print("No view controller selected.")
                return
            }

            do {
                let screenName = createNameFromViewController(viewController)
                let screenTemplate = try createBaseView(name: screenName)
                guard let content = try evaluateViewController(viewController) else {
                    return
                }

                let hydratedSwiftUIScreen = [
                    screenTemplate.replacingOccurrences(of: "{{ BODY }}", with: content),
                    (try? createLocalizedTextExtension(className: screenName)) ?? ""
                ].joined()

                let formattedCode = try SwiftFormatService().formatSwiftCode(hydratedSwiftUIScreen)
                print(formattedCode)
            } catch {
                print("Error: \(error)")
            }
        case .views(let views):
            let view = promptUserForSelection(items: views) { view in
                return createNameFromViewController(view)
            }

            guard let view else {
                print("No view selected.")
                return
            }

            do {
                let screenName = createNameFromView(view)
                let screenTemplate = try createBaseView(name: screenName)
                guard let knownSubview = filterOnlyKnownComponents(element: view).first as? XMLElement else {
                    print("No known subview found.")
                    return
                }
                let content = try evaluateSubviews(knownSubview)

                let hydratedSwiftUIScreen = [
                    screenTemplate.replacingOccurrences(of: "{{ BODY }}", with: content ?? ""),
                    (try? createLocalizedTextExtension(className: screenName)) ?? ""
                ].joined()

                let formattedCode = try SwiftFormatService().formatSwiftCode(hydratedSwiftUIScreen)
                print(formattedCode)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func determineStoryboardContentType(root: XMLElement) -> StoryboardContentType? {
        // Checks whether the storyboard contains a list of viewControllers
        if let scenes = root.elements(forName: "scenes").first {
            let sceneObjects = scenes.elements(forName: "scene")
            let objects = sceneObjects.flatMap { $0.elements(forName: "objects") }
            let viewControllers = objects.flatMap { $0.elements(forName: "viewController") }
            return .viewControllers(viewControllers)
        }
        
        // Checks whether the storyboard contains a list of views
        if let objects = root.elements(forName: "objects").first,
            let containerView = filterOnlyKnownComponents(element: objects).first as? XMLElement {
            return .views([containerView])
        }
        
        return nil
    }

    func filterOnlyKnownComponents(element: XMLElement) -> [XMLNode] {
        element.children?.compactMap { child in
            guard let elementName = child.name, let _ = SupportedElements(rawValue: elementName) else {
                return nil
            }
            
            return child
        } ?? []
    }

    func findOnlySubviews(element: XMLElement) -> [XMLNode] {
        element.children?.compactMap { child in
            guard let elementName = child.name, let supportedElement = SupportedElements(rawValue: elementName), supportedElement == .subviews else {
                return nil
            }

            return child
        } ?? []
    }

    func promptUserForSelection<T>(items: [T], itemNameProvider: (T) -> String) -> T? {
        print("Found \(items.count) items.")
        print("Please select one:")

        for (index, item) in items.enumerated() {
            print("\(index + 1): \(itemNameProvider(item))")
        }

        let selectedIndex = Int(readLine(strippingNewline: true) ?? "0") ?? 0
        guard selectedIndex > 0 && selectedIndex <= items.count else {
            print("Invalid selection. Please try again.")
            return nil
        }

        let selectedItem = items[selectedIndex - 1]
        return selectedItem
    }

    func createNameFromViewController(_ viewControllerNode: XMLElement) -> String {
        let defaultViewSuffix = "Screen"

        guard let customClass = viewControllerNode.attribute(forName: "customClass")?.stringValue else {
            print("Unable to identify customClass from viewController node element.")
            return defaultViewSuffix
        }

        return customClass.replacingOccurrences(of: "ViewController", with: defaultViewSuffix)
    }

    func createNameFromView(_ view: XMLElement) -> String {
        let defaultViewSuffix = "Screen"
        guard let customClass = view.attribute(forName: "customClass")?.stringValue else {
            print("Unable to identify customClass from viewController node element.")
            return defaultViewSuffix
        }

        return customClass
    }

    func evaluateViewController(_ viewController: XMLElement) throws -> String? {
        guard let containerView = viewController.elements(forName: "view").first else {
            print("Unable to find view in viewController element. Please check that the storyboard is valid.")
            return nil
        }
        
        return try evaluateSubviews(containerView)
    }
    
    func evaluateSubviews(_ containerView: XMLElement) throws -> String? {
        guard let template = try loadTemplate(name: "Body") else { throw ConversionError.failedToLoadTemplate }

        let subviews = containerView.elements(forName: "subviews")
        if subviews.isEmpty {
            return template.replacingOccurrences(of: "{{ CONTENT }}", with: evaluateViewElement(containerView))
        }

        let output = subviews.reduce("") { result, subview in
            return result + template.replacingOccurrences(of: "{{ CONTENT }}", with: evaluateViewElement(subview))
        }
        
        return output
    }
    
    /// Performs depth first search over all of the nodes in the Storyboard and creates the SwiftUI view on the way back from the leaf nodes to the root
    /// - Parameter node: The current storyboard element to process
    /// - Returns: The SwiftUI representation of the current XML node and all of it's children
    func evaluateViewElement(_ node: XMLNode) -> String {
        (node.children ?? []).compactMap { child in
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
                    return evaluateViewElement(element)
                case .textField:
                    return try createTextField(element)
                case .button:
                    return createButton(element)
                case .tableView:
                    return try createTableView(element)
                case .tableViewCell:
                    return evaluateViewElement(element)
                case .tableViewCellContentView:
                    return try createTableViewCellContentView(element)
                }
            } catch {
                print(error)
                return nil
            }
        }.joined(separator: "\n")
    }
    
    func loadTemplate(name: String) throws -> String? {
        guard let templateURL = Bundle.module.url(forResource: name, withExtension: "stencil"), let template = try? String(contentsOf: templateURL) else {
            print("Failed to load template file.")
            return nil
        }
        
        return template
    }
    
    // MARK: Hydration
    func createBaseView(name: String) throws -> String {
        guard let template = try loadTemplate(name: "Base") else { throw ConversionError.failedToLoadTemplate }

        let contentView = template.replacingOccurrences(of: "{{ SCREEN_NAME }}", with: name)
        return contentView
    }
    
    func createLabel(_ node: XMLElement) throws -> String {
        guard let template = try loadTemplate(name: "Label") else { throw ConversionError.failedToLoadTemplate }

        let text = node.attribute(forName: "text")?.stringValue ?? ""
        var output: String

        if text.isEmpty {
            output = template.replacingOccurrences(of: "{{ CONTENT }}", with: text)
        } else {
            localizedText.append(text)
            output = template.replacingOccurrences(of: "{{ CONTENT }}", with: text.camelCase)
        }

        return output
    }

    func createScrollView(_ node: XMLElement) throws -> String {
        guard let template = try loadTemplate(name: "ScrollView") else { throw ConversionError.failedToLoadTemplate }
        return template.replacingOccurrences(of: "{{ CONTENT }}", with: evaluateViewElement(node))
    }
    
    func createImage(_ node: XMLElement) throws -> String {
        guard let template = try loadTemplate(name: "Image") else { throw ConversionError.failedToLoadTemplate }
        
        var output = [String]()
        
        let imageName = node.attribute(forName: "image")?.stringValue?.camelCase ?? ""
        output.append(template.replacingOccurrences(of: "{{ CONTENT }}", with: imageName))
        
        if let frame = node.children?.first(where: { $0.name == "rect" }) as? XMLElement,
           let width = frame.attribute(forName: "width")?.stringValue,
           let height = frame.attribute(forName: "height")?.stringValue {
            output.append(".frame(width: \(width), height: \(height))")
        }
        
        return output.joined()
    }
    
    func createStackView(_ node: XMLElement) throws -> String {
        guard let vStackTemplate = try loadTemplate(name: "VStack"), let hStackTemplate = try loadTemplate(name: "HStack") else {
            throw ConversionError.failedToLoadTemplate
        }

        // TODO: This is only true for Turo
        let template = (node.attribute(forName: "axis")?.stringValue == "vertical") ? vStackTemplate : hStackTemplate

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
    
    func createTableView(_ node: XMLElement) throws -> String {
        guard let tableViewTemplate = try loadTemplate(name: "TableView") else {
            throw ConversionError.failedToLoadTemplate
        }

        guard let prototypes = node.children?.first(where: { $0.name == "prototypes" }),
              let tableViewCells = prototypes.children?.filter({ $0.name == "tableViewCell" }) else {
            return ""
        }

        let cells = tableViewCells.compactMap { evaluateViewElement($0) }.joined(separator: "\n")
        return tableViewTemplate.replacingOccurrences(of: "{{ CONTENT }}", with: cells)
    }

    func createTableViewCellContentView(_ node: XMLElement) throws -> String {
        guard let cellContentView = try loadTemplate(name: "TableViewCellContentView") else { throw ConversionError.failedToLoadTemplate }
        return cellContentView.replacingOccurrences(of: "{{ CONTENT }}", with: evaluateViewElement(node))
    }
    
    func createTextField(_ node: XMLElement) throws -> String {
        guard let textFieldTemplate = try loadTemplate(name: "TextField") else {
            throw ConversionError.failedToLoadTemplate
        }
        
        let placeholderText = node.attribute(forName: "placeholder")?.stringValue
        if let placeholderText {
            localizedText.append(placeholderText)
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

        guard !localizedText.isEmpty else {
            return ""
        }

        let localizedStringOutput = localizedText.map { localizedItem in
            localizedTextTemplate
                .replacingOccurrences(of: "{{ VARIABLE_NAME }}", with: localizedItem.camelCase)
                .replacingOccurrences(of: "{{ KEY }}", with: localizedItem.snakeCase)
                .replacingOccurrences(of: "{{ VALUE }}", with: localizedItem)
        }.joined(separator: "\n")

        // Can't combine this String here otherwise Xcode will treat is as a placeholder
        let defaultPlaceholder = "<" + "#T##String#" + ">"
        return localizedTextExtensionTemplate
            .replacingOccurrences(of: "{{ CONTENT }}", with: localizedStringOutput)
            .replacingOccurrences(of: "{{ CLASS_NAME }}", with: className)
            .replacingOccurrences(of: "{{ PLACEHOLDER }}", with: defaultPlaceholder)
    }
}
