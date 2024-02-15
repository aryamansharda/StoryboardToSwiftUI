import Foundation

@available(macOS 13.0, *)
@main
public struct StoryboardToSwiftUI {
    static let nameProvider: ViewControllerNameProvider = TuroViewControllerNameProvider()
    static let codeGenerator = CustomCodeGenerator()

    public static func main() {
        print("Please provide the absolute path to the .storyboard file:")
        
//        let filePath = "/Users/aryamansharda/Documents/bowman/Bowman/User Interface/Base.lproj/Extras.storyboard"
//        let filePath = "/Users/aryamansharda/Documents/bowman/Bowman/Classes/Views/Listing/Quality Acknowledgement/Base.lproj/ListingQualityAcknowledgement.storyboard"
//        let filePath = "/Users/aryamansharda/Documents/bowman/Bowman/Classes/Subclasses/Base.lproj/CheckoutPolicyCell.xib"
        let filePath = "/Users/aryamansharda/Documents/bowman/Bowman/User Interface/Base.lproj/ExtrasEditSectionHeader.xib"
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
        let url = URL(filePath: filePath)
        do {
            let xmlDoc = try XMLDocument(contentsOf: url, options: [])
            print(xmlDoc)
            let root = xmlDoc.rootElement()
            return root
        } catch {
            print(error)
            return nil
        }
    }
}
