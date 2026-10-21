//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

@objc(PBMHTMLFormatter)
class HTMLFormatter: NSObject {

    // The pattern is a literal, so creating the expression cannot fail.
    private static let htmlTagRegex = try! NSRegularExpression(pattern: "(<html>)|(</html>)", options: .caseInsensitive)

    @objc(ensureHTMLHasBodyAndHTMLTags:)
    public static func ensureHTMLHasBodyAndHTMLTags(_ html: String) -> String {
        // Remove any <html> / </html> tag
        let bodyText = htmlTagRegex.stringByReplacingMatches(in: html,
                                                             options: [],
                                                             range: NSRange(location: 0, length: (html as NSString).length),
                                                             withTemplate: "")

        // If string has no <body> tag, wrap the string in a body tag.
        let wrappedBody = wrapBodyIfNeeded(bodyText)

        // Wrap the string in a html tag.
        return wrapHTML(wrappedBody)
    }

    private static func wrapBodyIfNeeded(_ html: String) -> String {
        // NSString search, as `String.contains` disagrees when a grapheme-extending character follows the match
        let bodyRange = ((html as NSString).lowercased as NSString).range(of: "<body")
        if bodyRange.location == NSNotFound {
            return "<body>\(html)</body>"
        }
        return html
    }

    private static func wrapHTML(_ html: String) -> String {
        "<html>\(html)</html>"
    }
}
