//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/2/24.
//

import Foundation

protocol ViewControllerNameProvider {
    func createSwiftUINameFromViewController(_ viewControllerNode: XMLElement) -> String
}

struct StandardViewControllerNameProvider: ViewControllerNameProvider {
    func createSwiftUINameFromViewController(_ viewControllerNode: XMLElement) -> String {
        let defaultViewSuffix = "Screen"

        guard let customClass = viewControllerNode.attribute(forName: "customClass")?.stringValue else {
            print("Unable to identify customClass from viewController node element.")
            return defaultViewSuffix
        }

        return customClass.replacingOccurrences(of: "ViewController", with: defaultViewSuffix)
    }
}

struct TuroViewControllerNameProvider: ViewControllerNameProvider {
    func createSwiftUINameFromViewController(_ viewControllerNode: XMLElement) -> String {
        let defaultViewSuffix = "Screen"

        guard let customClass = viewControllerNode.attribute(forName: "customClass")?.stringValue else {
            print("Unable to identify customClass from viewController node element.")
            return defaultViewSuffix
        }

        return customClass
            .replacingOccurrences(of: "RR", with: "")
            .replacingOccurrences(of: "ViewController", with: defaultViewSuffix)
    }
}
