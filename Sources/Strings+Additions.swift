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

    var toCamelCase: String {
        let alphanumericInput = self
            .replacingOccurrences(of: "[^a-zA-Z0-9 ]", with: "", options: .regularExpression)
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
            .replacingOccurrences(of: "[^a-zA-Z0-9 ]", with: "", options: .regularExpression)
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
}
