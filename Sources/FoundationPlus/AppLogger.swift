//
//  AppLogger.swift
//  iOSNetwork
//
//  Created by Ram on 05/03/2025.
//

//Usage examples:
//
//```swift
//// Basic logging
//AppLogger.debug("Debug message")
//AppLogger.info("Info message")
//AppLogger.warning("Warning message")
//AppLogger.error("Error message")
//AppLogger.fault("Critical fault")
//
//// Category-specific logging
//AppLogger.network("API call completed")
//AppLogger.ui("View did appear")
//AppLogger.data("Data saved successfully")
//
//// Legacy support
//AppLogger.print("Old style logging")
//```
//
//This Logger provides:
//1. Different log levels (debug, info, warning, error, fault)
//2. Category-specific logging (network, UI, data)
//3. Debug-only logging for debug messages
//4. Emoji prefixes for better visibility in console
//5. Legacy support for the old print method
//6. Uses Apple's recommended os Logger

import os
import Foundation

public struct AppLogger {
    // MARK: - Log Categories
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.workfast.ai"
    
    public static let defaultLogger = Logger(subsystem: subsystem, category: "default")
    private static let networkLogger = Logger(subsystem: subsystem, category: "network")
    private static let uiLogger = Logger(subsystem: subsystem, category: "ui")
    private static let dataLogger = Logger(subsystem: subsystem, category: "data")
    
    // MARK: - Log Levels
    public static func debug(_ message: String, logger: Logger = defaultLogger) {
        #if DEBUG
        logger.debug("🟣 \(message)")
        #endif
    }
    
    public static func info(_ message: String, logger: Logger = defaultLogger) {
        logger.info("🔵 \(message)")
    }
    
    public static func warning(_ message: String, logger: Logger = defaultLogger) {
        logger.warning("🟡 \(message)")
    }
    
    public static func error(_ message: String, logger: Logger = defaultLogger) {
        logger.error("🔴 \(message)")
    }
    
    public static func critical(_ message: String, logger: Logger = defaultLogger) {
        logger.critical("⚫️ \(message)")
    }
    
    // MARK: - Convenience Methods
    public static func network(_ message: String) {
        debug(message, logger: networkLogger)
    }
    
    public static func ui(_ message: String) {
        debug(message, logger: uiLogger)
    }
    
    public static func data(_ message: String) {
        debug(message, logger: dataLogger)
    }
    
    // MARK: - Legacy Support
    public static func print(_ message: String) {
        debug(message)
    }
}
