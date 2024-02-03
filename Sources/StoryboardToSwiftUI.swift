import Foundation

@main
public struct StoryboardToSwiftUI {

    enum StoryboardContentType {
        case viewControllers([XMLElement])
        case views([XMLElement])
    }

    static let nameProvider: ViewControllerNameProvider = TuroViewControllerNameProvider()

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
                let screenContainer = createSwiftUIView(name: screenName)
                print(screenContainer)
            }
        case .views(let views):
            for view in views {

            }
        }
    }

    static func readXMLFile(filePath: String) -> XMLElement? {
        let url = URL(fileURLWithPath: filePath)
        guard let xmlDoc = try? XMLDocument(contentsOf: url, options: []), let root = xmlDoc.rootElement() else {
            return nil
        }

        return root
    }

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

    static func createSwiftUIView(name: String) -> String? {
        guard let templateURL = Bundle.main.url(forResource: "BaseSwiftUIView", withExtension: "stencil"), let template = try? String(contentsOf: templateURL) else {
            print("Failed to load template file.")
            return nil
        }

        let output = template.replacingOccurrences(of: "{{ SCREEN_NAME }}", with: name)
        return output
    }
}
