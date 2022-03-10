/*   Copyright 2018-2019 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

/// Enum which maps an appropiate symbol which added as prefix for each log message

public enum LogLevel: String {
    case debug = "[💬]" // debug
    case verbose = "[🔬]" // verbose
    case info = "[ℹ️]" // info
    case warn = "[⚠️]" // warning
    case error = "[‼️]" // error
    case severe = "[🔥]" // severe
}

//Objective-C Api
@objc
public enum LogLevel_: Int {
    case debug // debug
    case verbose // verbose
    case info // info
    case warn // warning
    case error // error
    case severe // severe
    
    func getPrimary() -> LogLevel {
        switch self {
        case .debug: return .debug
        case .verbose: return .verbose
        case .info: return .info
        case .warn: return .warn
        case .error: return .error
        case .severe: return .severe
        }
    }
}

/// Wrapping Swift.print() within DEBUG flag
///
/// - Note: *print()* might cause [security vulnerabilities](https://codifiedsecurity.com/mobile-app-security-testing-checklist-ios/)
///
/// - Parameter object: The object which is to be logged
///
func print(_ object: Any) {
    // Only allowing in DEBUG mode
    #if DEBUG
    Swift.print(object)
    #endif
}

class Log {

    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    static var logLevel: LogLevel = .debug

    private class func isLoggingEnabled(for currentEvent: LogLevel) -> Bool {
        #if !(DEBUG)
        return false
        #endif
        let currentLevel = PrebidConfiguration.shared.logLevel
        switch currentLevel {
        case .debug:
            return true
        case .verbose:
            return [ LogLevel.verbose, LogLevel.info, LogLevel.warn, LogLevel.error, LogLevel.severe].contains(currentEvent)
        case .info:
            return [ LogLevel.info, LogLevel.warn, LogLevel.error, LogLevel.severe].contains(currentEvent)
        case .warn:
            return [ LogLevel.warn, LogLevel.error, LogLevel.severe].contains(currentEvent)
        case .error:
            return [ LogLevel.error, LogLevel.severe].contains(currentEvent)
        case .severe:
            return [ LogLevel.severe].contains(currentEvent)
        }
    }

    // MARK: - Loging methods
    private class func log(level: LogLevel, _ object: Any, filename: String, line: Int, column: Int, funcName: String) {
        if isLoggingEnabled(for: level) {
            print("\(Date().toString()) \(level.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }

    /// Logs error messages on console with prefix [‼️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func error( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(level: .error, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs info messages on console with prefix [ℹ️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func info ( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(level: .info, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs debug messages on console with prefix [💬]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func debug( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
       log(level: .debug, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs messages verbosely on console with prefix [🔬]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func verbose( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(level: .verbose, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs warnings verbosely on console with prefix [⚠️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func warn( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(level: .warn, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Logs severe events on console with prefix [🔥]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func severe( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        log(level: .severe, object, filename: filename, line: line, column: column, funcName: funcName)
    }

    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}
