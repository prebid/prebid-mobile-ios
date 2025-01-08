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

/// This class serves as the central point for all logging operations within the SDK.
/// It allows for categorized logging based on severity levels (e.g., error, warning, debug) and offers options for both console and file-based logging.
/// It also provides the ability to set third-party logger.
@objc(PBMLog) @objcMembers
public class Log: NSObject {

    // MARK: - Public properties
    
    /// The current logging level. Only messages at this level or higher will be logged.
    public static var logLevel: LogLevel = .debug
    
    /// Indicates whether logs should also be saved to a file.
    public static var logToFile = false
    
    /// Sets a custom logger to handle log messages.
    public static func setCustomLogger(_ logger: PrebidLogger) {
        self.logger = logger
    }

    public static func error(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        logger.error(object, filename: filename, line: line, function: function)
    }

    public static func info(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        logger.info(object, filename: filename, line: line, function: function)
    }

    public static func debug(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        logger.debug(object, filename: filename, line: line, function: function)
    }

    public static func verbose(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        logger.verbose(object, filename: filename, line: line, function: function)
    }

    public static func warn(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        logger.warn(object, filename: filename, line: line, function: function)
    }

    public static func severe(_ object: Any, filename: String = #file, line: Int = #line, function: String = #function) {
        logger.severe(object, filename: filename, line: line, function: function)
    }
    
    public static func whereAmI(filename: String = #file, line: Int = #line, function: String = #function) {
        logger.whereAmI(filename: filename, line: line, function: function)
    }
    
    /// Writes a log message to the log file asynchronously.
    ///
    /// - Parameter message: The log message to be written to the file.
    public static func serialWriteToLog(_ message: String) {
        loggingQueue.async {
            writeToLogFile(message)
        }
    }
    
    /// Reads the contents of the log file as a single string.
    public static func getLogFileAsString() -> String? {
        loggingQueue.sync {
            if let logFileURL = logFileURL {
                do {
                    return try String(contentsOf: logFileURL, encoding: .utf8)
                } catch {
                    Log.error("\(PrebidConstants.SDK_NAME) Error getting log file: \(error.localizedDescription)")
                }
            }
            return nil
        }
    }
    
    /// Clears the contents of the log file.
    public static func clearLogFile() {
        loggingQueue.sync {
            do {
                if let logFileURL = logFileURL {
                    try "".data(using: .utf8)?.write(to: logFileURL)
                }
            } catch {
                Log.error("\(PrebidConstants.SDK_NAME) Error clearing log file: \(error.localizedDescription)")
            }
        }
    }
    
    static func writeToLogFile(_ message: String) {
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
                        Log.error("\(PrebidConstants.SDK_NAME) Couldn't write to log file: \(error.localizedDescription)")
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
                    Log.error("\(PrebidConstants.SDK_NAME) Couldn't write to log file URL: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private static var logger: PrebidLogger = SDKConsoleLogger()
    
    private static let loggingQueue = DispatchQueue(label: PrebidConstants.SDK_NAME)
    
    private static let logFileURL = URL.temporaryURL(for: PrebidConstants.SDK_NAME + ".txt")
}
