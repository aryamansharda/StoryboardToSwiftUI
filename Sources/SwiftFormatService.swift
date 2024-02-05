//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/4/24.
//

import Foundation

class SwiftFormat {
    static func run() {
        let process = Process()
        process.launchPath = "/usr/local/bin/swiftformat" // Adjust the path based on your installation
        process.arguments = ["."] // Specify the path to your project or the directory you want to format

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print(output)
        }
    }
}
