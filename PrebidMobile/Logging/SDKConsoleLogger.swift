//
//  SDKConsoleLogger.swift
//  PrebidMobile
//
//  Created by Jono Sligh on 7/25/24.
//  Copyright © 2024 AppNexus. All rights reserved.
//

import Foundation

public class SDKConsoleLogger: NSObject, PrebidLogger {
    
    public func error(_ object: Any, filename: String, line: Int, function: String) {
        log(object, logLevel: .error, filename: filename, line: line, function: function)
    }

    public func info(_ object: Any, filename: String, line: Int, function: String) {
        log(object, logLevel: .info, filename: filename, line: line, function: function)
    }

    public func debug(_ object: Any, filename: String, line: Int, function: String) {
        log(object, logLevel: .debug, filename: filename, line: line, function: function)
    }

    public func verbose(_ object: Any, filename: String, line: Int, function: String) {
        log(object, logLevel: .verbose, filename: filename, line: line, function: function)
    }

    public func warn(_ object: Any, filename: String, line: Int, function: String) {
        log(object, logLevel: .warn, filename: filename, line: line, function: function)
    }

    public func severe(_ object: Any, filename: String, line: Int, function: String) {
        log(object, logLevel: .severe, filename: filename, line: line, function: function)
    }

    public func whereAmI(filename: String, line: Int, function: String) {
        
    }

    public func log(_ object: Any, logLevel: LogLevel, filename: String, line: Int, function: String) {
        
    }
}
