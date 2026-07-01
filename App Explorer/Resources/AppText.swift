//
//  AppText.swift
//  App Explorer
//
//  Created by Codex on 2026/6/30.
//

import Foundation

enum LocalizedTextKey {
    case appsTab
    case aboutTab
    case subtitle
    case searchPlaceholder
    case visible
    case total
    case updated
    case scanning
    case ready
    case allApps
    case userApps
    case refresh
    case noApps
    case noMatch
    case tryAnotherKeyword
    case aboutSubtitle
    case language
    case openSource
    case currentVersion
    case contactAndLinks
    case telegramChannel
    case githubProfile
    case wechatOfficial
    case developerTools
    case infoPlistBrowser
    case urlSchemes
    case searchPlistPlaceholder
    case searchURLSchemesPlaceholder
    case declaredURLSchemes
    case queriedURLSchemes
    case copyAllSchemes
    case shareSchemes
    case exportSchemesTXT
    case dictionaryCount
    case arrayCount
    case exportCenter
    case quickActions
    case build
    case iconSize
    case originalSize
    case exportIconSize
    case version
    case buildNumber
    case displayName
    case bundleName
    case executable
    case minimumIOS
    case systemBadge
    case userApp
    case systemApp
    case bundleID
    case bundlePath
    case dataPath
    case applicationType
    case iconSource
    case copyBundleID
    case copyBundlePath
    case copyDataPath
    case exportAppIcon
    case exportEntitlements
    case iconReady
    case entitlementsReady
    case noIconAvailable
    case unavailable
    case backToApps
    case copied
    case scanFailed
}

enum AppText {
    static func text(_ key: LocalizedTextKey, language: AppLanguage) -> String {
        switch language {
        case .chinese:
            return chinese(key)
        case .english:
            return english(key)
        }
    }

    private static func chinese(_ key: LocalizedTextKey) -> String {
        switch key {
        case .appsTab: return "应用"
        case .aboutTab: return "关于"
        case .subtitle: return "为 TrollStore 设备快速查看应用信息。"
        case .searchPlaceholder: return "搜索应用或 Bundle ID"
        case .visible: return "显示"
        case .total: return "总数"
        case .updated: return "更新"
        case .scanning: return "扫描中"
        case .ready: return "就绪"
        case .allApps: return "全部应用"
        case .userApps: return "用户应用"
        case .refresh: return "刷新"
        case .noApps: return "没有找到应用。"
        case .noMatch: return "没有匹配结果"
        case .tryAnotherKeyword: return "换个关键词或刷新后再试。"
        case .aboutSubtitle: return "极简但高质量的 TrollStore 应用浏览工具。"
        case .language: return "语言"
        case .openSource: return "开源地址"
        case .currentVersion: return "当前版本"
        case .contactAndLinks: return "联系与链接"
        case .telegramChannel: return "Telegram"
        case .githubProfile: return "GitHub"
        case .wechatOfficial: return "公众号"
        case .developerTools: return "开发者工具"
        case .infoPlistBrowser: return "Info.plist 浏览器"
        case .urlSchemes: return "URL Schemes"
        case .searchPlistPlaceholder: return "搜索 Info.plist Key 或内容"
        case .searchURLSchemesPlaceholder: return "搜索 URL Scheme"
        case .declaredURLSchemes: return "声明的 URL Schemes"
        case .queriedURLSchemes: return "查询白名单 Schemes"
        case .copyAllSchemes: return "复制全部 Schemes"
        case .shareSchemes: return "分享 Schemes"
        case .exportSchemesTXT: return "导出 TXT"
        case .dictionaryCount: return "字典项"
        case .arrayCount: return "数组项"
        case .exportCenter: return "导出中心"
        case .quickActions: return "快捷操作"
        case .build: return "Build 2026"
        case .iconSize: return "图标规格"
        case .originalSize: return "原始尺寸"
        case .exportIconSize: return "导出 %@"
        case .version: return "版本"
        case .buildNumber: return "Build"
        case .displayName: return "显示名称"
        case .bundleName: return "Bundle 名称"
        case .executable: return "可执行文件"
        case .minimumIOS: return "最低 iOS"
        case .systemBadge: return "系统"
        case .userApp: return "用户应用"
        case .systemApp: return "系统应用"
        case .bundleID: return "Bundle ID"
        case .bundlePath: return "Bundle 路径"
        case .dataPath: return "数据路径"
        case .applicationType: return "应用类型"
        case .iconSource: return "图标来源"
        case .copyBundleID: return "复制 Bundle ID"
        case .copyBundlePath: return "复制 Bundle 路径"
        case .copyDataPath: return "复制数据路径"
        case .exportAppIcon: return "导出应用图标"
        case .exportEntitlements: return "导出 Entitlements"
        case .iconReady: return "图标已就绪"
        case .entitlementsReady: return "Entitlements 已就绪"
        case .noIconAvailable: return "当前应用没有可用图标。"
        case .unavailable: return "不可用"
        case .backToApps: return "应用"
        case .copied: return "已复制"
        case .scanFailed: return "扫描失败"
        }
    }

    private static func english(_ key: LocalizedTextKey) -> String {
        switch key {
        case .appsTab: return "Apps"
        case .aboutTab: return "About"
        case .subtitle: return "Fast app lookup for TrollStore devices."
        case .searchPlaceholder: return "Search apps or Bundle ID"
        case .visible: return "Visible"
        case .total: return "Total"
        case .updated: return "Updated"
        case .scanning: return "Scanning"
        case .ready: return "Ready"
        case .allApps: return "All Apps"
        case .userApps: return "User Apps"
        case .refresh: return "Refresh"
        case .noApps: return "No apps found."
        case .noMatch: return "No match"
        case .tryAnotherKeyword: return "Try another keyword or refresh the scan."
        case .aboutSubtitle: return "A minimal, polished app browser for TrollStore devices."
        case .language: return "Language"
        case .openSource: return "Open Source"
        case .currentVersion: return "Version"
        case .contactAndLinks: return "Links"
        case .telegramChannel: return "Telegram"
        case .githubProfile: return "GitHub"
        case .wechatOfficial: return "Official Account"
        case .developerTools: return "Developer Tools"
        case .infoPlistBrowser: return "Info.plist Browser"
        case .urlSchemes: return "URL Schemes"
        case .searchPlistPlaceholder: return "Search Info.plist keys or values"
        case .searchURLSchemesPlaceholder: return "Search URL schemes"
        case .declaredURLSchemes: return "Declared URL Schemes"
        case .queriedURLSchemes: return "Queried URL Schemes"
        case .copyAllSchemes: return "Copy All Schemes"
        case .shareSchemes: return "Share Schemes"
        case .exportSchemesTXT: return "Export TXT"
        case .dictionaryCount: return "Dictionary Items"
        case .arrayCount: return "Array Items"
        case .exportCenter: return "Export Center"
        case .quickActions: return "Quick Actions"
        case .build: return "Build 2026"
        case .iconSize: return "Icon Size"
        case .originalSize: return "Original"
        case .exportIconSize: return "Export %@"
        case .version: return "Version"
        case .buildNumber: return "Build"
        case .displayName: return "Display Name"
        case .bundleName: return "Bundle Name"
        case .executable: return "Executable"
        case .minimumIOS: return "Min iOS"
        case .systemBadge: return "System"
        case .userApp: return "User App"
        case .systemApp: return "System App"
        case .bundleID: return "Bundle ID"
        case .bundlePath: return "Bundle Path"
        case .dataPath: return "Data Path"
        case .applicationType: return "Application Type"
        case .iconSource: return "Icon Source"
        case .copyBundleID: return "Copy Bundle ID"
        case .copyBundlePath: return "Copy Bundle Path"
        case .copyDataPath: return "Copy Data Path"
        case .exportAppIcon: return "Export App Icon"
        case .exportEntitlements: return "Export Entitlements"
        case .iconReady: return "Icon Ready"
        case .entitlementsReady: return "Entitlements Ready"
        case .noIconAvailable: return "No icon is available for this app."
        case .unavailable: return "Unavailable"
        case .backToApps: return "Apps"
        case .copied: return "Copied"
        case .scanFailed: return "Scan Failed"
        }
    }
}
