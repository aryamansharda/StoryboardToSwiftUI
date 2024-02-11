import Foundation

enum SupportedElements: String {
    case label
    case scrollView
    case imageView
    case stackView
    case view
    case subviews
    case textField
    case button
    case tableView
    case tableViewCellContentView
}

enum StoryboardContentType {
    case viewControllers([XMLElement])
    case views([XMLElement])
}

@main
public struct StoryboardToSwiftUI {

    static let nameProvider: ViewControllerNameProvider = TuroViewControllerNameProvider()
    static let placeholder = "\"comments needed\"" //<" + "#T##String#" + ">"

    static let codeGenerator = CustomCodeGenerator()

    public static func main() {
        print("Please provide the absolute path to the .storyboard file:")
        
        let filePath = "/Users/aryamansharda/Documents/bowman/Bowman/User Interface/Base.lproj/Extras.storyboard"
        print(filePath)

        // Loads the Storyboard / View and returns the top-levl XML node
        guard let root = loadStoryboardFile(filePath: filePath) else {
            print("Unable to load valid XML data.")
            return
        }

        codeGenerator.generate(root: root)
    }

    // MARK: File I/O
    static func loadStoryboardFile(filePath: String) -> XMLElement? {
        let url = URL(fileURLWithPath: filePath)
        guard let xmlDoc = try? XMLDocument(contentsOf: url, options: []), let root = xmlDoc.rootElement() else {
            return nil
        }

        return root
    }
}
