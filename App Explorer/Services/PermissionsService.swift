//
//  PermissionsService.swift
//  App Explorer
//
//  Created by Codex on 2026/7/2.
//

import Foundation

struct AppPermissionReason: Identifiable, Hashable, Sendable {
    let key: String
    let value: String

    var id: String { key }
}

enum AppPermissionKind: String, CaseIterable, Identifiable, Sendable {
    case camera
    case microphone
    case location
    case photos
    case contacts
    case notifications
    case bluetooth

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .camera:
            return "camera.fill"
        case .microphone:
            return "mic.fill"
        case .location:
            return "location.fill"
        case .photos:
            return "photo.on.rectangle.angled"
        case .contacts:
            return "person.crop.circle.fill"
        case .notifications:
            return "bell.badge.fill"
        case .bluetooth:
            return "bolt.horizontal.circle.fill"
        }
    }
}

struct AppPermission: Identifiable, Hashable, Sendable {
    let kind: AppPermissionKind
    let reasons: [AppPermissionReason]
    let detectionDetails: [String]

    var id: String { kind.id }

    var primaryReason: String? {
        reasons.first?.value
    }
}

enum PermissionsService {
    static func loadPermissions(for app: InstalledApp) throws -> [AppPermission] {
        let infoPlist = try InfoPlistBrowserService.loadDictionary(for: app)
        let entitlements = (try? EntitlementsBrowserService.loadDictionary(for: app)) ?? [:]

        return PermissionDefinition.allCases.compactMap { definition in
            makePermission(
                definition: definition,
                infoPlist: infoPlist,
                entitlements: entitlements
            )
        }
    }

    private static func makePermission(
        definition: PermissionDefinition,
        infoPlist: [String: Any],
        entitlements: [String: Any]
    ) -> AppPermission? {
        let reasons: [AppPermissionReason] = definition.infoPlistKeys.compactMap { key -> AppPermissionReason? in
            guard let value = stringValue(for: key, in: infoPlist) else {
                return nil
            }

            return AppPermissionReason(key: key, value: value)
        }

        var detectionDetails: [String] = definition.entitlementDetectors.compactMap { detector -> String? in
            detector(entitlements)
        }

        detectionDetails.append(contentsOf: definition.infoPlistDetectors.compactMap { detector -> String? in
            detector(infoPlist)
        })

        guard !reasons.isEmpty || !detectionDetails.isEmpty else {
            return nil
        }

        return AppPermission(
            kind: definition.kind,
            reasons: reasons,
            detectionDetails: detectionDetails
        )
    }

    private static func stringValue(for key: String, in dictionary: [String: Any]) -> String? {
        guard let value = dictionary[key] as? String else {
            return nil
        }

        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return value
    }
}

private enum PermissionDefinition: CaseIterable {
    case camera
    case microphone
    case location
    case photos
    case contacts
    case notifications
    case bluetooth

    typealias Detector = ([String: Any]) -> String?

    var kind: AppPermissionKind {
        switch self {
        case .camera:
            return .camera
        case .microphone:
            return .microphone
        case .location:
            return .location
        case .photos:
            return .photos
        case .contacts:
            return .contacts
        case .notifications:
            return .notifications
        case .bluetooth:
            return .bluetooth
        }
    }

    var infoPlistKeys: [String] {
        switch self {
        case .camera:
            return ["NSCameraUsageDescription"]
        case .microphone:
            return ["NSMicrophoneUsageDescription"]
        case .location:
            return [
                "NSLocationWhenInUseUsageDescription",
                "NSLocationAlwaysAndWhenInUseUsageDescription",
                "NSLocationAlwaysUsageDescription"
            ]
        case .photos:
            return [
                "NSPhotoLibraryUsageDescription",
                "NSPhotoLibraryAddUsageDescription"
            ]
        case .contacts:
            return ["NSContactsUsageDescription"]
        case .notifications:
            return []
        case .bluetooth:
            return [
                "NSBluetoothAlwaysUsageDescription",
                "NSBluetoothPeripheralUsageDescription"
            ]
        }
    }

    var entitlementDetectors: [Detector] {
        switch self {
        case .notifications:
            return [
                { entitlements in
                    guard let environment = entitlements["aps-environment"] as? String,
                          !environment.isEmpty else {
                        return nil
                    }

                    return "aps-environment: \(environment)"
                }
            ]
        default:
            return []
        }
    }

    var infoPlistDetectors: [Detector] {
        switch self {
        case .notifications:
            return [
                { infoPlist in
                    guard let modes = infoPlist["UIBackgroundModes"] as? [String],
                          modes.contains("remote-notification") else {
                        return nil
                    }

                    return "UIBackgroundModes: remote-notification"
                }
            ]
        default:
            return []
        }
    }
}
