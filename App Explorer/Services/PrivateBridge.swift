//
//  PrivateBridge.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import Foundation
import Darwin
import ObjectiveC.runtime
import UIKit

struct AppProxySnapshot: Sendable {
    let bundleIdentifier: String
    let localizedName: String
    let bundleURL: URL?
    let dataContainerURL: URL?
    let bundleVersion: String
    let shortVersionString: String
    let minimumSystemVersion: String?
    let isSystemApp: Bool
    let applicationType: String
    let isLaunchProhibited: Bool
    let isRestricted: Bool
    let iconData: Data?
    let iconStatus: String
    let entitlementsData: Data?
}

enum PrivateBridgeError: LocalizedError {
    case workspaceUnavailable
    case selectorUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .workspaceUnavailable:
            return "LSApplicationWorkspace is unavailable."
        case .selectorUnavailable(let selector):
            return "Required selector is unavailable: \(selector)."
        }
    }
}

enum PrivateBridge {
    nonisolated static func fetchExportIconData(bundleIdentifier: String) -> Data? {
        if let data = loadUIImageIconData(
            for: bundleIdentifier,
            formats: [2, 1, 0, 6],
            scales: [3.0, 2.0, 1.0]
        ) {
            return data
        }

        return loadSpringBoardIconData(for: bundleIdentifier)
    }

    nonisolated static func fetchInstalledApplications() throws -> [AppProxySnapshot] {
        guard
            let workspaceClass = NSClassFromString("LSApplicationWorkspace"),
            let defaultWorkspace = performObjectSelector(
                on: workspaceClass,
                selector: "defaultWorkspace"
            )
        else {
            throw PrivateBridgeError.workspaceUnavailable
        }

        let applications = applicationObjects(from: defaultWorkspace)
        return applications.compactMap { makeSnapshot(from: $0) }
    }

    nonisolated private static func applicationObjects(from workspace: AnyObject) -> [AnyObject] {
        let candidateSelectors = [
            "allInstalledApplications",
            "allApplications"
        ]

        for selectorName in candidateSelectors {
            if let result = performObjectSelector(on: workspace, selector: selectorName) as? [AnyObject] {
                return result
            }
        }

        return []
    }

    nonisolated private static func makeSnapshot(from proxy: AnyObject) -> AppProxySnapshot? {
        guard let bundleIdentifier = readString(on: proxy, selector: "applicationIdentifier"), !bundleIdentifier.isEmpty else {
            return nil
        }

        let localizedName = readString(on: proxy, selector: "localizedName")
            ?? readString(on: proxy, selector: "itemName")
            ?? bundleIdentifier

        let bundleURL = readURL(on: proxy, selector: "bundleURL")
        let dataContainerURL = readURL(on: proxy, selector: "dataContainerURL")
            ?? readURL(on: proxy, selector: "containerURL")

        let bundleVersion = readString(on: proxy, selector: "bundleVersion")
            ?? readString(on: proxy, selector: "version")
            ?? ""

        let shortVersionString = readString(on: proxy, selector: "shortVersionString")
            ?? readString(on: proxy, selector: "bundleShortVersionString")
            ?? bundleVersion

        let minimumSystemVersion = readString(on: proxy, selector: "minimumSystemVersion")
        let isSystemApp = readBool(on: proxy, selector: "isSystemApplication")
            ?? readBool(on: proxy, selector: "systemApplication")
            ?? false
        let applicationType = readString(on: proxy, selector: "applicationType")
            ?? (isSystemApp ? "System" : "User")
        let isLaunchProhibited = readBool(on: proxy, selector: "isLaunchProhibited") ?? false
        let isRestricted = readBool(on: proxy, selector: "isRestricted") ?? false

        let iconResult = loadIconData(from: proxy, bundleIdentifier: bundleIdentifier)
        let entitlementsData = loadEntitlementsData(from: proxy)

        return AppProxySnapshot(
            bundleIdentifier: bundleIdentifier,
            localizedName: localizedName,
            bundleURL: bundleURL,
            dataContainerURL: dataContainerURL,
            bundleVersion: bundleVersion,
            shortVersionString: shortVersionString,
            minimumSystemVersion: minimumSystemVersion,
            isSystemApp: isSystemApp,
            applicationType: applicationType,
            isLaunchProhibited: isLaunchProhibited,
            isRestricted: isRestricted,
            iconData: iconResult.data,
            iconStatus: iconResult.status,
            entitlementsData: entitlementsData
        )
    }

    nonisolated private static func loadEntitlementsData(from proxy: AnyObject) -> Data? {
        let selectors = [
            "entitlements",
            "_entitlements",
            "signatureInfo"
        ]

        for selectorName in selectors {
            guard let object = performObjectSelector(on: proxy, selector: selectorName) else {
                continue
            }

            if let dictionary = object as? [String: Any],
               let data = try? PropertyListSerialization.data(
                fromPropertyList: dictionary,
                format: .xml,
                options: 0
               ) {
                return data
            }

            if let dictionary = object as? NSDictionary,
               let data = try? PropertyListSerialization.data(
                fromPropertyList: dictionary,
                format: .xml,
                options: 0
               ) {
                return data
            }

            if selectorName == "signatureInfo",
               let dictionary = object as? [String: Any] {
                let entitlementKeys = [
                    "Entitlements",
                    "entitlements"
                ]

                for key in entitlementKeys {
                    if let entitlements = dictionary[key] as? [String: Any],
                       let data = try? PropertyListSerialization.data(
                        fromPropertyList: entitlements,
                        format: .xml,
                        options: 0
                       ) {
                        return data
                    }
                }
            }
        }

        return nil
    }

    nonisolated private static func loadIconData(from proxy: AnyObject, bundleIdentifier: String) -> (data: Data?, status: String) {
        if let uiImageIconData = loadUIImageIconData(
            for: bundleIdentifier,
            formats: [2, 1, 0, 6, 10, 11, 12],
            scales: [3.0, 2.0, 1.0]
        ) {
            return (uiImageIconData, "UIImage private icon API")
        }

        if let springBoardIconData = loadSpringBoardIconData(for: bundleIdentifier) {
            return (springBoardIconData, "SpringBoardServices")
        }

        if let iconResult = loadProxyIconData(from: proxy) {
            return iconResult
        }

        return (nil, "No system icon API matched")
    }

    nonisolated private static func loadUIImageIconData(
        for bundleIdentifier: String,
        formats: [Int],
        scales: [Double]
    ) -> Data? {
        let target = UIImage.self as AnyObject

        for format in formats {
            for scale in scales {
                if let data = performUIImageIconSelector(
                    on: target,
                    selector: "_applicationIconImageForBundleIdentifier:format:scale:",
                    bundleIdentifier: bundleIdentifier,
                    format: format,
                    scale: scale
                ) {
                    return data
                }
            }
        }

        for format in formats {
            if let data = performUIImageIconSelector(
                on: target,
                selector: "_applicationIconImageForBundleIdentifier:format:",
                bundleIdentifier: bundleIdentifier,
                format: format,
                scale: nil
            ) {
                return data
            }
        }

        return nil
    }

    nonisolated private static func loadProxyIconData(from proxy: AnyObject) -> (data: Data, status: String)? {
        let dataSelectors = [
            "primaryIconDataForVariant:withOptions:",
            "iconDataForVariant:withOptions:",
            "primaryIconDataForVariant:",
            "iconDataForVariant:"
        ]

        for selectorName in dataSelectors {
            for variant in [2, 3, 1, 0] {
                if let data = performIconDataSelector(on: proxy, selector: selectorName, variant: variant) {
                    return (data, "\(selectorName) variant \(variant)")
                }
            }
        }

        let imageSelectors = [
            "applicationIconImageForFormat:scale:",
            "applicationIconImageForFormat:"
        ]

        for selectorName in imageSelectors {
            for format in [2, 1, 0, 10, 12] {
                for scale in [3.0, 2.0, 1.0] {
                    if let data = performIconImageSelector(on: proxy, selector: selectorName, format: format, scale: scale) {
                        return (data, "\(selectorName) format \(format)")
                    }
                }
            }
        }

        return nil
    }

    nonisolated private static func loadSpringBoardIconData(for bundleIdentifier: String) -> Data? {
        let frameworkPath = "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"
        guard let handle = dlopen(frameworkPath, RTLD_LAZY) else {
            return nil
        }
        defer { dlclose(handle) }

        if let symbol = dlsym(handle, "SBSCopyIconImagePNGDataForDisplayIdentifier") {
            typealias CopyIconDataFunction = @convention(c) (CFString) -> Unmanaged<CFData>?
            let function = unsafeBitCast(symbol, to: CopyIconDataFunction.self)

            if let iconData = function(bundleIdentifier as CFString)?.takeRetainedValue() {
                return iconData as Data
            }
        }

        if let symbol = dlsym(handle, "SBSCopyIconImagePathForDisplayIdentifier") {
            typealias CopyIconPathFunction = @convention(c) (CFString) -> Unmanaged<CFString>?
            let function = unsafeBitCast(symbol, to: CopyIconPathFunction.self)

            if let iconPath = function(bundleIdentifier as CFString)?.takeRetainedValue() as String?,
               let data = try? Data(contentsOf: URL(fileURLWithPath: iconPath)) {
                return data
            }
        }

        return nil
    }

    nonisolated private static func performObjectSelector(on target: AnyObject, selector: String) -> AnyObject? {
        let sel = NSSelectorFromString(selector)
        guard target.responds(to: sel) else { return nil }

        typealias Function = @convention(c) (AnyObject, Selector) -> Unmanaged<AnyObject>?
        let implementation = target.method(for: sel)
        let function = unsafeBitCast(implementation, to: Function.self)
        return function(target, sel)?.takeUnretainedValue()
    }

    nonisolated private static func performIconDataSelector(on target: AnyObject, selector: String, variant: Int) -> Data? {
        let sel = NSSelectorFromString(selector)
        guard target.responds(to: sel) else { return nil }

        let implementation = target.method(for: sel)
        let value: AnyObject?

        if selector.hasSuffix(":withOptions:") {
            typealias Function = @convention(c) (AnyObject, Selector, Int, NSDictionary?) -> Unmanaged<AnyObject>?
            let function = unsafeBitCast(implementation, to: Function.self)
            value = function(target, sel, variant, nil)?.takeUnretainedValue()
        } else {
            typealias Function = @convention(c) (AnyObject, Selector, Int) -> Unmanaged<AnyObject>?
            let function = unsafeBitCast(implementation, to: Function.self)
            value = function(target, sel, variant)?.takeUnretainedValue()
        }

        return value as? Data
    }

    nonisolated private static func performIconImageSelector(on target: AnyObject, selector: String, format: Int, scale: Double) -> Data? {
        let sel = NSSelectorFromString(selector)
        guard target.responds(to: sel) else { return nil }

        let implementation = target.method(for: sel)
        let value: AnyObject?

        if selector.hasSuffix(":scale:") {
            typealias Function = @convention(c) (AnyObject, Selector, Int, Double) -> Unmanaged<AnyObject>?
            let function = unsafeBitCast(implementation, to: Function.self)
            value = function(target, sel, format, scale)?.takeUnretainedValue()
        } else {
            typealias Function = @convention(c) (AnyObject, Selector, Int) -> Unmanaged<AnyObject>?
            let function = unsafeBitCast(implementation, to: Function.self)
            value = function(target, sel, format)?.takeUnretainedValue()
        }

        if let image = value as? UIImage {
            return image.pngData()
        }

        return value as? Data
    }

    nonisolated private static func performUIImageIconSelector(
        on target: AnyObject,
        selector: String,
        bundleIdentifier: String,
        format: Int,
        scale: Double?
    ) -> Data? {
        let sel = NSSelectorFromString(selector)
        guard target.responds(to: sel) else { return nil }

        let implementation = target.method(for: sel)
        let value: AnyObject?

        if let scale {
            typealias Function = @convention(c) (AnyObject, Selector, NSString, Int, Double) -> Unmanaged<AnyObject>?
            let function = unsafeBitCast(implementation, to: Function.self)
            value = function(target, sel, bundleIdentifier as NSString, format, scale)?.takeUnretainedValue()
        } else {
            typealias Function = @convention(c) (AnyObject, Selector, NSString, Int) -> Unmanaged<AnyObject>?
            let function = unsafeBitCast(implementation, to: Function.self)
            value = function(target, sel, bundleIdentifier as NSString, format)?.takeUnretainedValue()
        }

        guard let image = value as? UIImage else {
            return value as? Data
        }

        return image.pngData()
    }

    nonisolated private static func readString(on target: AnyObject, selector: String) -> String? {
        performObjectSelector(on: target, selector: selector) as? String
    }

    nonisolated private static func readURL(on target: AnyObject, selector: String) -> URL? {
        performObjectSelector(on: target, selector: selector) as? URL
    }

    nonisolated private static func readBool(on target: AnyObject, selector: String) -> Bool? {
        let sel = NSSelectorFromString(selector)
        guard target.responds(to: sel) else { return nil }

        typealias Function = @convention(c) (AnyObject, Selector) -> Bool
        let implementation = target.method(for: sel)
        let function = unsafeBitCast(implementation, to: Function.self)
        return function(target, sel)
    }
}
