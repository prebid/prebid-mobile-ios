/*   Copyright 2018-2023 Prebid.org, Inc.

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

import UIKit

extension String {
    
    func isValidURL() -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        
        // It is a link, if the match covers the whole string
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        }
        
        return false
    }
    
    func encodedURL(with characterSet: CharacterSet) -> URL? {
        if let url = URL(string: self) {
            return url
        }
        
        if let encodedURLString = addingPercentEncoding(withAllowedCharacters: characterSet),
            let url = URL(string: encodedURLString) {
            return url
        }
        
        return nil
    }
    
    func containsOnly(_ characterSet: CharacterSet) -> Bool {
        return self.trimmingCharacters(in: characterSet).count == 0
    }
    
    /// Returns the last component of a file path, typically the file name.
    ///
    /// - Returns: The file name as a `String`, or an empty string if the path is empty.
    func sourceFileName() -> String {
        let pathComponents = components(separatedBy: "/")
        return pathComponents.last ?? ""
    }
    
    func toCGSize() -> CGSize? {
        let sizeArr = self.split(separator: "x").map(String.init)
        
        guard sizeArr.count == 2 else {
            Log.warn("\(self) has a wrong format")
            return nil
        }
        
        let nsNumberWidth = NumberFormatter().number(from: sizeArr[0])
        let nsNumberHeight = NumberFormatter().number(from: sizeArr[1])
        
        guard let numberWidth = nsNumberWidth, let numberHeight = nsNumberHeight else {
            Log.warn("\(self) can not be converted to CGSize")
            return nil
        }
        
        let width = CGFloat(truncating: numberWidth)
        let height = CGFloat(truncating: numberHeight)
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Regex Extensions

extension String {

    func matchAndCheck(regex: String) -> String? {
        let matched = self.matches(for: regex)
        return matched.isEmpty ? nil : matched[0]
    }

    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map { String(self[Range($0.range, in: self)!]) }
        } catch {
            Log.warn("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
