import Foundation

// Entry point of the application, available on macOS 13.0 and later
@available(macOS 13.0, *)
@main
public struct StoryboardToSwiftUI {
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

        // Generate code based on the loaded storyboard
        codeGenerator.generate(root: root)
    }

    // MARK: File I/O
    static func loadStoryboardFile(filePath: String) -> XMLElement? {
        let url = URL(filePath: filePath)
        do {
            // Try to create an XML document from the contents of the file
            let xmlDoc = try XMLDocument(contentsOf: url, options: [])
            let root = xmlDoc.rootElement()
            return root
        } catch {
            print(error)
            return nil
        }
    }
}
