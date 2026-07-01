//
//  IconService.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import UIKit

final class IconService: @unchecked Sendable {
    static let shared = IconService()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 300
    }

    func image(bundleID: String, iconData: Data?) -> UIImage? {
        let cacheKey = bundleID as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        guard let iconData, let image = UIImage(data: iconData) else {
            return nil
        }

        cache.setObject(image, forKey: cacheKey)
        return image
    }

    func image(for app: InstalledApp, iconData: Data?) -> UIImage? {
        image(bundleID: app.bundleID, iconData: iconData)
    }

    func preload(_ iconMap: [String: Data]) {
        for (bundleID, data) in iconMap {
            _ = image(bundleID: bundleID, iconData: data)
        }
    }
}
