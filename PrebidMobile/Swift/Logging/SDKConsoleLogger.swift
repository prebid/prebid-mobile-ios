/*   Copyright 2018-2024 Prebid.org, Inc.

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

/// A logger implementation for Prebid SDK that logs messages to the console.
@objc
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
        log("", logLevel: .info, filename: filename, line: line, function: function)
    }

    func log(_ object: Any, logLevel: LogLevel, filename: String, line: Int, function: String) {
        if isLoggingEnabled(for: logLevel) {
            let finalMessage = "\(PrebidConstants.SDK_NAME): \(Date().toString()) \(logLevel.stringValue)[\(filename.sourceFileName())]:\(line) \(function) -> \(object)"
            print(finalMessage)
            Log.serialWriteToLog(finalMessage)
        }
    }
    
    // MARK: - Private methods
    
    private func isLoggingEnabled(for currentLevel: LogLevel) -> Bool {
        #if !(DEBUG)
        return false
        #endif
        
        if currentLevel.rawValue < Log.logLevel.rawValue {
            return false
        }
        
        return true
    }
}

fileprivate extension Date {
    
    func toString() -> String {
        let dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.string(from: self as Date)
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
