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
}
