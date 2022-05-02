//
//  RigiLogger.swift
//  Rigi
//
//  Created by Dimitri van Oijen on 02/05/2022.
//

import Foundation

public var debugLoggingEnabled = false

enum RigiLogLevel: String {
    case debug = "debug", verbose = "verbose", warning = "warning", error = "error"
}

class RigiLogger {
    public static func log(_ level: RigiLogLevel = .verbose, _ message: String, _ error: Error? = nil) {
        if !Rigi.shared.settings.loggingEnabled {
            return
        }
        if !debugLoggingEnabled && (level == .debug) {
            return
        }
        let string: [String?] = [message, error?.localizedDescription]
        print("[Rigi] <\(level.rawValue)>:", string.compactMap{ $0 }.joined(separator: ", "))
    }
}
