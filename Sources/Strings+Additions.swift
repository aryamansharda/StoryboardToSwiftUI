//
//  Strings+Additions.swift
//  StoryboardToSwiftUIConverter
//
//  Created by Aryaman Sharda on 11/12/23.
//

import Foundation

extension String {
    var nearestPowerOf2: Int? {
        // Convert the input string to an integer
        guard let number = Int(self) else {
            return nil // Return nil if the conversion fails
        }

        // Find the nearest power of 2
        let nearestPowerOf2 = Int(pow(2, round(log2(Double(number)))))
        return nearestPowerOf2
    }

    var camelCase: String {
        let alphanumericInput = self
            .replacingOccurrences(of: "[^a-zA-Z ]", with: "", options: .regularExpression)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
            .prefix(5)
            .map { $0.lowercased() }

        guard !alphanumericInput.isEmpty else {
            return ""
        }

        let camelCaseString = alphanumericInput.dropFirst().reduce(alphanumericInput.first!) { result, word in
            return result + word.capitalized
        }

        return camelCaseString
    }

    var snakeCase: String {
        let alphanumericInput = self
            .replacingOccurrences(of: "[^a-zA-Z ]", with: "", options: .regularExpression)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
            .prefix(5)
            .map { $0.lowercased() }

        guard !alphanumericInput.isEmpty else {
            return ""
        }

        let snakeCaseString = alphanumericInput.joined(separator: "_")
        return snakeCaseString
    }

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
