//
//  ApiManagerHelper+Logger.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 NetProtect. All rights reserved.
//

import Foundation
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
