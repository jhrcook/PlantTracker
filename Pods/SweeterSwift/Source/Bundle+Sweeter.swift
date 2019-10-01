//
//  Bundle+Sweeter.swift
//
//  Created by Yonat Sharon on 2019-02-08.
//

import Foundation

extension Bundle {
    /// SweeterSwift: app name with reasonable fallback to process name
    public var name: String {
        return infoDictionary?["CFBundleDisplayName"] as? String
            ?? infoDictionary?["CFBundleName"] as? String
            ?? ProcessInfo.processInfo.processName
    }

    /// SweeterSwift: app name, version, and build number
    public var infoString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String
        let build = infoDictionary?["CFBundleVersion"] as? String

        let nameAndVersion = [name, version].compact.joined(separator: " ")
        return [nameAndVersion, build].compact.joined(separator: " #")
    }
}
