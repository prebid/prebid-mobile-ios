/*   Copyright 2018-2021 Prebid.org, Inc.

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

let OMValidationScript = "<script src=\"http://127.0.0.1:66/omid-validation-verification-script.js\"></script>\n"

extension String {
    init?(acjWithHtmlFileName htmlFileName: String, width:Int = 320, height:Int = 50) {
        
        guard var html = UtilitiesForTesting.loadFileAsStringFromBundle(htmlFileName) else {
            fatalError("Could not load \(htmlFileName) from Bundle")
        }
        
        // Some MRAID mocks starts with <html> (e.g. MRAID Expand - 1 Part)
        // In this case we have to insert VV script in proper place
        if html.starts(with: "<html>") {
            if let scriptIndex = html.range(of: "<script>")?.lowerBound {
                html.insert(contentsOf: OMValidationScript, at: scriptIndex)
            }
        }
        else {
            html = OMValidationScript + html
        }

        let bundleURL = Bundle.main.resourceURL!.absoluteString
        html = html.replacingOccurrences(of: "BUNDLE_URL_TOKEN", with: bundleURL)
        
        html = html.replacingOccurrences(of: "/", with: "\\/")
        html = html.replacingOccurrences(of: "\"", with: "\\\"")
        html = html.replacingOccurrences(of: "\n", with: "\\n")
        html = html.replacingOccurrences(of: "\r", with: "\\r")
        html = html.replacingOccurrences(of: "\t", with: "\\t")
        
        
        let acjFileName = "acj_template.json"
        guard var acj = UtilitiesForTesting.loadFileAsStringFromBundle(acjFileName) else {
            fatalError("Could not load \(acjFileName) from Bundle")
        }
        
        acj = acj.replacingOccurrences(of: "HTML_TOKEN", with: html)
        acj = acj.replacingOccurrences(of: "WIDTH_TOKEN", with: String(width))
        acj = acj.replacingOccurrences(of: "HEIGHT_TOKEN", with: String(height))

        logInfo("file:\(htmlFileName), width:\(width), height:\(height) acj:\n\(acj)")
        
        self.init(acj)
    }
    
    init?(acjFromJSONFileName fileName: String) {
        guard let acj = UtilitiesForTesting.loadFileAsStringFromBundle(fileName) else {
            fatalError("Could not load \(fileName) from Bundle")
        }
        self.init(acj)
    }
}
