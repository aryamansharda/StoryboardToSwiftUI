//
//  File.swift
//  
//
//  Created by Aryaman Sharda on 2/2/24.
//

import Foundation

protocol ViewControllerNameProvider {
    func createNameFromViewController(_ viewControllerNode: XMLElement) -> String
    func createNameFromView(_ view: XMLElement) -> String
}

struct StandardViewControllerNameProvider: ViewControllerNameProvider {
    func createNameFromViewController(_ viewControllerNode: XMLElement) -> String {
        let defaultViewSuffix = "Screen"

        guard let customClass = viewControllerNode.attribute(forName: "customClass")?.stringValue else {
            print("Unable to identify customClass from viewController node element.")
            return defaultViewSuffix
        }

        return customClass.replacingOccurrences(of: "ViewController", with: defaultViewSuffix)
    }

    func createNameFromView(_ view: XMLElement) -> String {
        let defaultViewSuffix = "Screen"
        guard let customClass = view.attribute(forName: "customClass")?.stringValue else {
            print("Unable to identify customClass from viewController node element.")
            return defaultViewSuffix
        }

        return customClass
    }
}

struct TuroViewControllerNameProvider: ViewControllerNameProvider {
    func createNameFromViewController(_ viewControllerNode: XMLElement) -> String {
        let defaultViewSuffix = "Screen"

        guard let customClass = viewControllerNode.attribute(forName: "customClass")?.stringValue else {
            print("Unable to identify customClass from viewController node element.")
            return defaultViewSuffix
        }

        return customClass
            .replacingOccurrences(of: "RR", with: "")
            .replacingOccurrences(of: "ViewController", with: defaultViewSuffix)
    }

    func createNameFromView(_ view: XMLElement) -> String {
        let defaultViewSuffix = "Screen"
        guard let customClass = view.attribute(forName: "customClass")?.stringValue else {
            print("Unable to identify customClass from viewController node element.")
            return defaultViewSuffix
        }

        return customClass
            .replacingOccurrences(of: "RR", with: "")
    }
}
