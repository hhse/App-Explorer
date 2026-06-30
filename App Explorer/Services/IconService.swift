//
//  IconService.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import UIKit

@MainActor
final class IconService {
    static let shared = IconService()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 300
    }

    func image(for app: InstalledApp, iconData: Data?) -> UIImage? {
        let cacheKey = app.bundleID as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        guard let iconData, let image = UIImage(data: iconData) else {
            return nil
        }

        cache.setObject(image, forKey: cacheKey)
        return image
    }
}
