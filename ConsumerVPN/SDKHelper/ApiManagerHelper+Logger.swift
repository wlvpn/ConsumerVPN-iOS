//
//  ApiManagerHelper+Logger.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 NetProtect. All rights reserved.
//

import Foundation

private enum DiagnosticsAppEventLog {
    private static let fileName = "consumervpn-diagnostics-events.log"
    private static let queue = DispatchQueue(label: "com.wlvpn.consumervpn.diagnostics.events")
    // Sized from observed VPNKit behavior: a single connect/disconnect can emit ~10-15 lines
    // when retries occur, so 1000 events covers weeks of normal use without unbounded growth.
    private static let maxRetainedEvents = 1000
    private static let trimTriggerSizeInBytes: UInt64 = 100 * 1024

    static func append(_ message: String) {
        queue.sync {
            guard let logURL = fileURL() else { return }

            let timestamp = ISO8601DateFormatter().string(from: Date())
            let logLine = "\(timestamp) [ConsumerVPN] \(message)\n"

            do {
                let directoryURL = logURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                excludeFromBackup(directoryURL)

                if FileManager.default.fileExists(atPath: logURL.path),
                   let fileHandle = try? FileHandle(forWritingTo: logURL) {
                    defer {
                        try? fileHandle.close()
                    }

                    fileHandle.seekToEndOfFile()
                    if let data = logLine.data(using: .utf8) {
                        fileHandle.write(data)
                    }
                } else {
                    try logLine.write(to: logURL, atomically: true, encoding: .utf8)
                }

                trimIfNeeded(at: logURL)
            } catch {
                debugPrint("[ConsumerVPN] Failed to append diagnostics app event: \(error.localizedDescription)")
            }
        }
    }

    private static func trimIfNeeded(at logURL: URL) {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: logURL.path),
              let fileSize = attributes[.size] as? UInt64,
              fileSize > trimTriggerSizeInBytes,
              let content = try? String(contentsOf: logURL, encoding: .utf8) else { return }

        let retainedLines = content.split(separator: "\n", omittingEmptySubsequences: true).suffix(maxRetainedEvents)
        guard retainedLines.isEmpty == false else { return }

        let trimmedContent = retainedLines.joined(separator: "\n") + "\n"
        try? trimmedContent.write(to: logURL, atomically: true, encoding: .utf8)
    }

    // Application Support is backed up by default; diagnostics data doesn't need to survive
    // a device restore, so it's excluded explicitly.
    private static func excludeFromBackup(_ url: URL) {
        var mutableURL = url
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try? mutableURL.setResourceValues(resourceValues)
    }

    static func clear() {
        queue.sync {
            guard let logURL = fileURL() else { return }
            try? FileManager.default.removeItem(at: logURL)
        }
    }

    static func loadContent() -> String? {
        return queue.sync {
            guard let logURL = fileURL(),
                  let content = try? String(contentsOf: logURL, encoding: .utf8),
                  content.contains(where: { !$0.isWhitespace }) else {
                return nil
            }

            return content
        }
    }

    private static func fileURL() -> URL? {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Diagnostics", isDirectory: true)
            .appendingPathComponent(fileName)
    }
}

//MARK: Log For Diagnostics
extension ApiManagerHelper {
    
    func logLevel() -> VPNLogLevel{
        return apiManager.logLevel()
    }
    
    func logFile() -> String? {
        return apiManager.logFile()
    }
    
    func setLogLevel(_ level: VPNLogLevel) {
        apiManager.setLogLevel(level)
    }
    
    func clearLogs() {
        apiManager.clearLogs()
        DiagnosticsAppEventLog.clear()
    }

    func appendDiagnosticEvent(_ message: String) {
        guard logLevel() != .off else { return }

        DiagnosticsAppEventLog.append(message)
    }

    func appDiagnosticEventLogContent() -> String? {
        return DiagnosticsAppEventLog.loadContent()
    }
    
    func loadServerListIfExists() -> Data? {
        
        if let apiAdapter = apiManager.apiAdapter as? V3APIAdapter,
           let coreDataURL = apiAdapter.getOption(kV3CoreDataURL) as? URL {
            let serverListURL = coreDataURL.deletingLastPathComponent().appendingPathComponent(kV3ServerListFileKey)
            do {
                let data = try Data(contentsOf: serverListURL)
                return data
            } catch {
            }
        }
        return nil
    }

}
