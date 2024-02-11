//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/4/24.
//

import SwiftFormat
import SwiftSyntax

class SwiftFormatService {
    func formatSwiftCode(_ code: String) throws -> String {
        let input = tokenize(code)
        let output: [Token]

//        do {
//
//        } catch {
//            throw
//        }

        output = try! format(input)
        print(sourceCode(for: output))
        // Parse the input code
//        let sourceFile = try SyntaxParser.parse(source: code)
//
//        // Create a SwiftFormat configuration
//        let configuration = Configuration()
//
//        // Create a SwiftFormat formatter
//        let formatter = SwiftFormatter(configuration: configuration)
//
//        // Format the parsed syntax tree
//        let formattedSource = try formatter.format(sourceFile: sourceFile).description

        return code
    }
}
