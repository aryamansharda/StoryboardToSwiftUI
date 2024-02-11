//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/4/24.
//

import SwiftFormat
import SwiftSyntax

final class SwiftFormatService {
    func formatSwiftCode(_ code: String) throws -> String {
        let input = tokenize(code)
        let output = try format(input)
        return sourceCode(for: output)
    }
}
