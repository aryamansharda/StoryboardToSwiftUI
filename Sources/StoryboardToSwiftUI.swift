import Foundation

@main
public struct StoryboardToSwiftUI {

    enum StoryboardContentType {
        case viewControllers([XMLElement])
        case views([XMLElement])
    }

    enum SupportedElements: String {
        case label
        case scrollView
        case imageView
        case stackView
        case view
        case subviews
        case textField
        case button
    }

    enum ConversionError: Error {
        case failedToLoadTemplate
    }

    static let nameProvider: ViewControllerNameProvider = TuroViewControllerNameProvider()
    static let placeholder = "<" + "#T##String#" + ">"

    static var actionNames = [String]()
    static var localizedText = [String]()

    public static func main() {
        // Loads the Storyboard / View and returns the top-levl XML node
        let filePath = "/Users/aryamansharda/Documents/bowman/Bowman/User Interface/Base.lproj/BoostPricingInfoViewController.storyboard"
        guard let rootNode = readXMLFile(filePath: filePath) else {
            print("Unable to load valid XML data.")
            return
        }

        guard let contentType = identifyStoryboardContentType(root: rootNode) else {
            print("Unable to determine .storyboard file contents.")
            return
        }

        switch contentType {
        case .viewControllers(let viewControllers):
            for viewController in viewControllers {
                let screenName = nameProvider.createSwiftUINameFromViewController(viewController)
                
                guard let screenTemplate = createBaseView(name: screenName), let content = evaluateViewController(viewController) else {
                    continue
                }

//                let body = evaluateViewController(viewController)

                let hydratedSwiftUIScreen = screenTemplate.replacingOccurrences(of: "{{ BODY }}", with: content)
                print(hydratedSwiftUIScreen)
            }
        case .views(let views):
            for view in views {

            }
        }
    }

    // MARK: File I/O
    static func readXMLFile(filePath: String) -> XMLElement? {
        let url = URL(fileURLWithPath: filePath)
        guard let xmlDoc = try? XMLDocument(contentsOf: url, options: []), let root = xmlDoc.rootElement() else {
            return nil
        }

        return root
    }

    // MARK: Pre-Processing
    static func identifyStoryboardContentType(root: XMLElement) -> StoryboardContentType? {
        // Checks whether the storyboard contains a list of viewControllers
        if let scenes = root.elements(forName: "scenes").first {
            let sceneObjects = scenes.elements(forName: "scene")
            let objects = sceneObjects.flatMap { $0.elements(forName: "objects") }
            let viewControllers = objects.flatMap { $0.elements(forName: "viewController") }
            return .viewControllers(viewControllers)
        }

        // Checks whether the storyboard contains a list of views
        if let objects = root.elements(forName: "objects").first {
            let views = objects.elements(forName: "view")
            return .views(views)
        }

        return nil
    }

    static func retrieveViewName(_ view: XMLElement) -> String {
        let defaultViewSuffix = "View"
        var recommendedClassName = defaultViewSuffix

        if var retrievedCustomClass = view.attribute(forName: "customClass")?.stringValue {
            retrievedCustomClass = retrievedCustomClass.replacingOccurrences(of: "RR", with: "")
            recommendedClassName = retrievedCustomClass
        }

        return recommendedClassName
    }

    // MARK: ~Hydration
    static func createBaseView(name: String) -> String? {
        guard let templateURL = Bundle.module.url(forResource: "Base", withExtension: "stencil"), let template = try? String(contentsOf: templateURL) else {
            print("Failed to load template file.")
            return nil
        }

        let output = template.replacingOccurrences(of: "{{ SCREEN_NAME }}", with: name)
        return output
    }

    static func evaluateViewController(_ viewController: XMLElement) -> String? {
        guard let containerView = viewController.elements(forName: "view").first else {
            print("Unable to find view in viewController element. Please check that the storyboard is valid.")
            return nil
        }

        return evaluateSubviews(containerView)
    }

    static func evaluateSubviews(_ containerView: XMLElement) -> String? {
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

    static func evaluateViewElement(_ node: XMLNode) -> String {
        guard node.childCount != 0 else {
            // This node is a leaf node
            // Leaf node, perform the action
            // TODO: This might be when it's an unrecognized component
            return node.name ?? "" + "\n"
        }

        return (node.children ?? []).compactMap { child in
            guard let name = child.name, let type = SupportedElements(rawValue: name), let element = child as? XMLElement else {
                print("Unrecognized UI element type: \(child.debugDescription)")
                return ""
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
                    return createStackView(element)
                case .view:
                    return createView(element)
                case .subviews:
                    return createSubviews(element)
                case .textField:
                    return createTextField(element)
                case .button:
                    return createButton(element)
                }
            } catch {
                print(error)
                return nil
            }
        }.joined()
    }

    // Use the template to add anything you want on all of them, then you can use this to add anything you want on a case by case basis
    // The goal is that someone can easily come in and replace this with their own implementation
    // So, you're thinking just give them the XMLNode and all of the data and they can use the template + their business logic to generate the ouptut string

    static func loadTemplate(name: String) throws -> String? {
        guard let templateURL = Bundle.module.url(forResource: name, withExtension: "stencil"), let template = try? String(contentsOf: templateURL) else {
            print("Failed to load template file.")
            return nil
        }

        return template
    }

    static func createLabel(_ node: XMLElement) throws -> String {
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
            output.append(".textToken(\(className.textToken)))")
        }

        return output.joined()
    }

    static func createScrollView(_ node: XMLElement) throws -> String {
        guard let template = try loadTemplate(name: "ScrollView") else { throw ConversionError.failedToLoadTemplate }
        return template.replacingOccurrences(of: "{{ CONTENT }}", with: evaluateViewElement(node))
    }

    static func createImage(_ node: XMLElement) throws -> String {
        guard let template = try loadTemplate(name: "Image") else { throw ConversionError.failedToLoadTemplate }

        var output = [String]()

        let imageName = node.attribute(forName: "image")?.stringValue ?? ""
        output.append(template.replacingOccurrences(of: "{{ CONTENT }}", with: imageName))

        if let contentMode = node.attribute(forName: "contentMode")?.stringValue {
            output.append( ".aspectRatio(contentMode: .\(contentMode))")
        }

        return output.joined()
    }

    static func createStackView(_ node: XMLElement) -> String {
        ""
    }

    static func createView(_ node: XMLElement) -> String {
        guard let customClass = node.attribute(forName: "customClass")?.stringValue else {
            return evaluateViewElement(node)
        }

        print("An unknown type was detected. To add support, please add support for \(customClass) to the known types.")
        return "// \(customClass)"
    }

    static func createSubviews(_ node: XMLElement) -> String {
        ""
    }

    static func createTextField(_ node: XMLElement) -> String {
        ""
    }

    static func createButton(_ node: XMLElement) -> String {
        ""
    }
}
