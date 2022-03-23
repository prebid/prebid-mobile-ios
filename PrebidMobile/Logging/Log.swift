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

@objcMembers
public class Log: NSObject {

    // MARK: - Public properties
    
    public static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    public static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    public static var logLevel: LogLevel = .debug
    public static var logToFile = false

    public static func error(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        log(object, logLevel: .error, filename: filename, line: line, function: function)
    }

    public static func info(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        log(object, logLevel: .info, filename: filename, line: line, function: function)
    }

    public static func debug(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        log(object, logLevel: .debug, filename: filename, line: line, function: function)
    }

    public static func verbose(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        log(object, logLevel: .verbose, filename: filename, line: line, function: function)
    }

    public static func warn(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        log(object, logLevel: .warn, filename: filename, line: line, function: function)
    }

    public static func severe(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        log(object, logLevel: .severe, filename: filename, line: line, function: function)
    }
    
    public static func whereAmI(filename: String = #file, line: Int = #line, function: String = #function) {
        log("", logLevel: .info, filename: filename, line: line, function: function)
    }
    
    static func log(_ object: Any, logLevel: LogLevel, filename: String, line: Int, function: String) {
        if isLoggingEnabled(for: logLevel) {
            let finalMessage = "\(sdkName): \(Date().toString()) \(logLevel.stringValue)[\(sourceFileName(filePath: filename))]:\(line) \(function) -> \(object)"
            print(finalMessage)
            serialWriteToLog(finalMessage)
        }
    }
    
    public static func serialWriteToLog(_ message: String) {
        loggingQueue.async {
            writeToLogFile(message)
        }
    }
    
    public static func writeToLogFile(_ message: String) {
        if !Log.logToFile {
            return
        }
        
        let messageWithNewline = message + "\n"
        guard let data = messageWithNewline.data(using: .utf8) else {
            return
        }
        
        if let path = logFileURL?.path, FileManager.default.fileExists(atPath: path) {
            if let fileHandle = FileHandle(forWritingAtPath: path) {
                
                if #available(iOS 13.4, *) {
                    do {
                        try fileHandle.seekToEnd()
                        try fileHandle.write(contentsOf: data)
                        try fileHandle.close()
                    } catch {
                        Log.error("\(sdkName) Couldn't write to log file: \(error.localizedDescription)")
                    }
                } else {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            }
        } else {
            if let logFileURL = logFileURL {
                do {
                    try data.write(to: logFileURL)
                } catch {
                    Log.error("\(sdkName) Couldn't write to log file URL: \(error.localizedDescription)")
                }
            }
        }
    }
    
    public static func getLogFileAsString() -> String? {
        loggingQueue.sync {
            if let logFileURL = logFileURL {
                do {
                    return try String(contentsOf: logFileURL, encoding: .utf8)
                } catch {
                    Log.error("\(sdkName) Error getting log file: \(error.localizedDescription)")
                }
            }
            return nil
        }
    }
    
    public static func clearLogFile() {
        loggingQueue.sync {
            do {
                if let logFileURL = logFileURL {
                    try "".data(using: .utf8)?.write(to: logFileURL)
                }
            } catch {
                Log.error("\(sdkName) Error clearing log file: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Internal properties and methods
    
    private static let sdkName = "prebid-mobile-sdk"
    
    private static let loggingQueue = DispatchQueue(label: sdkName)
    
    private static var logFileURL = getURLForDoc(sdkName + ".txt")
    
    private class func isLoggingEnabled(for currentLevel: LogLevel) -> Bool {
        #if !(DEBUG)
        return false
        #endif
        
        if currentLevel.rawValue < Log.logLevel.rawValue {
            return false
        }
        
        return true
    }
    
    private static func getURLForDoc(_ docName: String) -> URL? {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        return temporaryDirectoryURL.appendingPathComponent(docName)
    }
    
    private static func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
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
