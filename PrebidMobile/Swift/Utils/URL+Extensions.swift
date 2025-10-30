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

extension URL {
    
    static func urlWithoutEncoding(from str: String?) -> URL? {
        guard let str = str else {
            return nil
        }
        
        if #available(iOS 17.0, *) {
            return URL(string: str, encodingInvalidCharacters: false)
        }
        
        return URL(string: str)
    }
    
    /// Returns a URL for a document stored in the temporary directory.
    static func temporaryURL(for docName: String) -> URL? {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        return temporaryDirectoryURL.appendingPathComponent(docName)
    }
}
