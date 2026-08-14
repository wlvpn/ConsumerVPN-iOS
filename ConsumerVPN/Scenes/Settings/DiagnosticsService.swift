//
//  DiagnosticsService.swift
//  ConsumerVPN
//
//  Created by Javier Hernández on 8/4/26.
//  Copyright © 2026 NetProtect. All rights reserved.
//

import Foundation
import UIKit
import VPNKit

struct DiagnosticsDeviceInfo {
    let deviceModel: String
    let deviceID: String
    let iOSVersion: String
    let vpnKitVersion: String
    
    var formattedText: String {
        return LocalizedString.diagnosticsDeviceInfo(
            deviceModel: deviceModel,
            deviceID: deviceID,
            iOSVersion: iOSVersion,
            vpnKitVersion: vpnKitVersion
        )
    }
}

final class DiagnosticsService {
    
    private struct LogSection {
        let title: String
        let content: String
    }

    private let diagnosticsExportNameToken = "-WLVPN-iOS-"
    private let fallbackDiagnosticsExportName = "WLVPN-iOS-Diagnostics.log"
    private let apiManagerHelper: ApiManagerHelper
    
    init(apiManagerHelper: ApiManagerHelper = .shared) {
        self.apiManagerHelper = apiManagerHelper
    }
    
    func logLevel() -> VPNLogLevel {
        return apiManagerHelper.logLevel()
    }
    
    func setLogLevel(_ level: VPNLogLevel) {
        apiManagerHelper.setLogLevel(level)
    }
    
    func clearLogs() {
        apiManagerHelper.clearLogs()
        removeGeneratedShareFiles()
    }
    
    func loadLogContent() -> String? {
        let sections = logSections()

        guard sections.isEmpty == false else { return nil }

        return sections
            .map { "\($0.title)\n\($0.content)" }
            .joined(separator: "\n\n")
    }
    
    func deviceInfo() -> DiagnosticsDeviceInfo {
        let device = UIDevice.current
        
        return DiagnosticsDeviceInfo(
            deviceModel: hardwareModel(),
            deviceID: device.identifierForVendor?.uuidString ?? LocalizedString.unavailable,
            iOSVersion: "\(device.systemName) \(device.systemVersion)",
            vpnKitVersion: vpnKitVersion()
        )
    }
    
    func attachmentContent(withLogContent logContent: String) -> String {
        return "\(deviceInfo().formattedText)\n\n\(logContent)"
    }
    
    func makeShareFile(withLogContent logContent: String) throws -> URL {
        removeGeneratedShareFiles()

        let fileName = generateFileName() ?? "WLVPN-iOS-Diagnostics.log"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let content = attachmentContent(withLogContent: logContent)
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }

    func removeShareFile(at fileURL: URL) {
        guard isGeneratedDiagnosticsExport(fileURL) else { return }

        try? FileManager.default.removeItem(at: fileURL)
    }
    
    func generateFileName() -> String? {
        guard let infoDict = Bundle.main.infoDictionary,
              let version = infoDict["CFBundleShortVersionString"] else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        return "\(dateString)-WLVPN-iOS-\(version).log"
    }
    
    func loadServerListIfExists() -> Data? {
        return apiManagerHelper.loadServerListIfExists()
    }

    private func logSections() -> [LogSection] {
        var sections: [LogSection] = []

        if let appEventsContent = apiManagerHelper.appDiagnosticEventLogContent() {
            sections.append(LogSection(title: LocalizedString.diagnosticsAppEventsLog, content: appEventsContent))
        }

        if let vpnKitContent = loadVPNKitLogContent() {
            sections.append(LogSection(title: LocalizedString.diagnosticsVPNKitLog, content: vpnKitContent))
        }

        return sections
    }

    private func loadVPNKitLogContent() -> String? {
        guard let logPath = apiManagerHelper.logFile() else {
            return nil
        }

        let logURL = URL(fileURLWithPath: logPath)
        let logFileURLs = vpnKitLogFileURLs(in: logURL.deletingLastPathComponent())

        let content = logFileURLs
            .compactMap { try? String(contentsOf: $0, encoding: .utf8) }
            .filter { $0.contains(where: { !$0.isWhitespace }) }
            .joined(separator: "\n")

        guard content.contains(where: { !$0.isWhitespace }) else { return nil }

        return content
    }

    private func vpnKitLogFileURLs(in directoryURL: URL) -> [URL] {
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .creationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return fileURLs
            .filter { $0.pathExtension == "log" }
            .sorted { lhs, rhs in
                return logSortDate(for: lhs) < logSortDate(for: rhs)
            }
    }

    private func logSortDate(for fileURL: URL) -> Date {
        let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .creationDateKey])

        return resourceValues?.contentModificationDate ??
            resourceValues?.creationDate ??
            Date.distantPast
    }

    private func removeGeneratedShareFiles() {
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: FileManager.default.temporaryDirectory,
            includingPropertiesForKeys: nil
        ) else { return }

        fileURLs
            .filter(isGeneratedDiagnosticsExport)
            .forEach { try? FileManager.default.removeItem(at: $0) }
    }

    private func isGeneratedDiagnosticsExport(_ fileURL: URL) -> Bool {
        let fileName = fileURL.lastPathComponent

        return fileURL.pathExtension == "log" &&
            (fileName.contains(diagnosticsExportNameToken) || fileName == fallbackDiagnosticsExportName)
    }

    private func vpnKitVersion() -> String {
        guard let vpnKitInfo = Bundle(identifier: "com.wlvpn.VPNKit")?.infoDictionary,
              let shortVersion = vpnKitInfo["CFBundleShortVersionString"] as? String,
              let buildVersion = vpnKitInfo["CFBundleVersion"] as? String else {
            return LocalizedString.unknown
        }
        
        return "\(shortVersion)_\(buildVersion)"
    }
    
    private func hardwareModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        return String(
            bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)),
            encoding: .ascii
        )?.trimmingCharacters(in: .controlCharacters) ?? UIDevice.current.model
    }
    
}
