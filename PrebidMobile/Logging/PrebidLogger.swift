/*   Copyright 2018-2025 Prebid.org, Inc.
 
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

/// A protocol defining methods for logging messages at various levels.
///
/// Implement this protocol to handle logging in a customizable way.
@objc public protocol PrebidLogger {
    
    /// Logs an error message.
    ///
    /// - Parameters:
    ///   - object: The object or message to log.
    ///   - filename: The name of the file where the log was generated.
    ///   - line: The line number where the log was generated.
    ///   - function: The function name where the log was generated.
    func error(_ object: Any, filename: String, line: Int, function: String)
    
    /// Logs an informational message.
    ///
    /// - Parameters:
    ///   - object: The object or message to log.
    ///   - filename: The name of the file where the log was generated.
    ///   - line: The line number where the log was generated.
    ///   - function: The function name where the log was generated.
    func info(_ object: Any, filename: String, line: Int, function: String)
    
    /// Logs a debug message.
    ///
    /// - Parameters:
    ///   - object: The object or message to log.
    ///   - filename: The name of the file where the log was generated.
    ///   - line: The line number where the log was generated.
    ///   - function: The function name where the log was generated.
    func debug(_ object: Any, filename: String, line: Int, function: String)
    
    /// Logs a verbose message, typically used for detailed or low-level information.
    ///
    /// - Parameters:
    ///   - object: The object or message to log.
    ///   - filename: The name of the file where the log was generated.
    ///   - line: The line number where the log was generated.
    ///   - function: The function name where the log was generated.
    func verbose(_ object: Any, filename: String, line: Int, function: String)
    
    /// Logs a warning message.
    ///
    /// - Parameters:
    ///   - object: The object or message to log.
    ///   - filename: The name of the file where the log was generated.
    ///   - line: The line number where the log was generated.
    ///   - function: The function name where the log was generated.
    func warn(_ object: Any, filename: String, line: Int, function: String)
    
    /// Logs a severe error message, indicating a critical issue.
    ///
    /// - Parameters:
    ///   - object: The object or message to log.
    ///   - filename: The name of the file where the log was generated.
    ///   - line: The line number where the log was generated.
    ///   - function: The function name where the log was generated.
    func severe(_ object: Any, filename: String, line: Int, function: String)
    
    /// Logs the current location in the code.
    ///
    /// - Parameters:
    ///   - filename: The name of the file where this method was called.
    ///   - line: The line number where this method was called.
    ///   - function: The function name where this method was called.
    func whereAmI(filename: String, line: Int, function: String)
}
