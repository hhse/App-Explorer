//
//  IconExportService.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import UIKit

struct IconExportResult {
    let url: URL
    let data: Data
    let fileName: String
}

enum IconExportSize: String, CaseIterable, Identifiable {
    case original
    case size1024
    case size180
    case size120

    var id: String { rawValue }

    var pixels: CGFloat? {
        switch self {
        case .original:
            return nil
        case .size1024:
            return 1024
        case .size180:
            return 180
        case .size120:
            return 120
        }
    }

    func title(language: AppLanguage) -> String {
        switch self {
        case .original:
            return AppText.text(.originalSize, language: language)
        case .size1024:
            return "1024x1024"
        case .size180:
            return "180x180"
        case .size120:
            return "120x120"
        }
    }

    var fileSuffix: String {
        switch self {
        case .original:
            return ""
        case .size1024:
            return "_1024"
        case .size180:
            return "_180"
        case .size120:
            return "_120"
        }
    }
}

enum IconExportService {
    static func export(icon: UIImage, appName: String, bundleID: String, size: IconExportSize) throws -> IconExportResult {
        let fileName = "\(safeFileName(appName))\(size.fileSuffix).png"
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("AppExplorerExports", isDirectory: true)

        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let url = directoryURL
            .appendingPathComponent(fileName)
        let exportImage = bestExportImage(fallbackIcon: icon, bundleID: bundleID)

        guard let data = renderPNGData(from: exportImage, targetPixelSize: size.pixels) else {
            throw IconExportError.renderFailed
        }

        try data.write(to: url, options: .atomic)

        guard FileManager.default.fileExists(atPath: url.path) else {
            throw IconExportError.fileMissing
        }

        return IconExportResult(url: url, data: data, fileName: fileName)
    }

    private static func bestExportImage(fallbackIcon: UIImage, bundleID: String) -> UIImage {
        guard let data = PrivateBridge.fetchExportIconData(bundleIdentifier: bundleID),
              let image = UIImage(data: data) else {
            return fallbackIcon
        }

        guard looksLikeAppIcon(image) else {
            return fallbackIcon
        }

        let fallbackPixels = max(fallbackIcon.size.width * fallbackIcon.scale, fallbackIcon.size.height * fallbackIcon.scale)
        let candidatePixels = max(image.size.width * image.scale, image.size.height * image.scale)

        return candidatePixels >= fallbackPixels ? image : fallbackIcon
    }

    private static func looksLikeAppIcon(_ image: UIImage) -> Bool {
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        guard width > 0, height > 0 else {
            return false
        }

        let ratio = width / height
        guard ratio > 0.92, ratio < 1.08 else {
            return false
        }

        return !hasDocumentIconWhiteBorder(image)
    }

    private static func hasDocumentIconWhiteBorder(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage,
              let provider = cgImage.dataProvider,
              let data = provider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return false
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = max(cgImage.bitsPerPixel / 8, 1)
        let samplePoints = [
            CGPoint(x: 0.10, y: 0.10),
            CGPoint(x: 0.90, y: 0.10),
            CGPoint(x: 0.10, y: 0.90),
            CGPoint(x: 0.90, y: 0.90)
        ]

        let whiteSamples = samplePoints.filter { point in
            let x = min(max(Int(CGFloat(width - 1) * point.x), 0), width - 1)
            let y = min(max(Int(CGFloat(height - 1) * point.y), 0), height - 1)
            let offset = y * bytesPerRow + x * bytesPerPixel
            guard offset + 2 < CFDataGetLength(data) else { return false }

            let red = bytes[offset]
            let green = bytes[offset + 1]
            let blue = bytes[offset + 2]
            return red > 238 && green > 238 && blue > 238
        }

        return whiteSamples.count >= 3
    }

    private static func renderPNGData(from image: UIImage, targetPixelSize: CGFloat?) -> Data? {
        let currentPixels = max(image.size.width * image.scale, image.size.height * image.scale)
        let targetPixels = targetPixelSize ?? currentPixels
        let targetSize = CGSize(width: targetPixels, height: targetPixels)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return renderedImage?.pngData() ?? image.pngData()
    }

    private static func safeFileName(_ text: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let fileName = text.components(separatedBy: invalidCharacters)
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return fileName.isEmpty ? "App" : fileName
    }
}

enum IconExportError: LocalizedError {
    case renderFailed
    case fileMissing

    var errorDescription: String? {
        switch self {
        case .renderFailed:
            return "Could not render the icon as PNG."
        case .fileMissing:
            return "The exported PNG file could not be found."
        }
    }
}
