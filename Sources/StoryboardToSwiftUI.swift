import Foundation

// Entry point of the application, available on macOS 13.0 and later
@available(macOS 13.0, *)
@main
public struct StoryboardToSwiftUI {
    static let codeGenerator = CustomCodeGenerator()

    public static func main() {
        print("Please provide the absolute path to the .storyboard file:")
      
        // Read user input for file path
        guard let filePath = readLine() else {
            print("Invalid file path provided.")
            return
        }

        // Loads the Storyboard / View and returns the top-levl XML node
        guard let root = loadStoryboardFile(filePath: filePath) else {
            print("Unable to load valid XML data.")
            return
        }

        // Generate code based on the loaded storyboard
        guard let response = codeGenerator.generate(root: root) else {
            print("Conversion failed!")
            return
        }

        print(response)
        copyToClipboard(text: response)
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

    // MARK: Clipboard
    static func copyToClipboard(text: String) {
        let process = Process()
        process.launchPath = "/usr/bin/pbcopy"
        process.arguments = ["-pboard", "general", "-"]

        let pipe = Pipe()
        process.standardInput = pipe

        if let data = text.data(using: .utf8) {
            pipe.fileHandleForWriting.write(data)
            pipe.fileHandleForWriting.closeFile()
        }

        process.launch()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("Text copied to clipboard successfully.")
        } else {
            print("Failed to copy text to clipboard.")
        }
    }
}
