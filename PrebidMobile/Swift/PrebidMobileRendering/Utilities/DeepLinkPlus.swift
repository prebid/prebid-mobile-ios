/*   Copyright 2018-2021 Prebid.org, Inc.

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

@objc(PBMDeepLinkPlus)
public class DeepLinkPlus: NSObject {

    @objc public let primaryURL: URL
    @objc public let fallbackURL: URL?
    @objc public let primaryTrackingURLs: [URL]?
    @objc public let fallbackTrackingURLs: [URL]?

    // Internal designated init (also used by convenience init? below)
    init(primaryURL: URL,
         fallbackURL: URL?,
         primaryTrackingURLs: [URL]?,
         fallbackTrackingURLs: [URL]?) {
        self.primaryURL           = primaryURL
        self.fallbackURL          = fallbackURL
        self.primaryTrackingURLs  = primaryTrackingURLs
        self.fallbackTrackingURLs = fallbackTrackingURLs
        super.init()
    }

    // Swift convenience init — mirrors the ObjC factory selector deepLinkPlusWithURL:
    public convenience init?(url: URL) {
        guard let deep = DeepLinkPlus.deepLinkPlus(with: url) else { return nil }
        self.init(primaryURL: deep.primaryURL,
                  fallbackURL: deep.fallbackURL,
                  primaryTrackingURLs: deep.primaryTrackingURLs,
                  fallbackTrackingURLs: deep.fallbackTrackingURLs)
    }

    @objc(deepLinkPlusWithURL:)
    public static func deepLinkPlus(with url: URL) -> DeepLinkPlus? {
        var primaryURL: URL?
        var fallbackURL: URL?
        var primaryTrackingURLs: [URL]?
        var fallbackTrackingURLs: [URL]?

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        for item in components?.queryItems ?? [] {
            guard let valueURL = urlWithoutEncoding(from: item.value) else { continue }
            switch item.name {
            case "primaryUrl":
                if primaryURL == nil { primaryURL = valueURL }
            case "fallbackUrl":
                if fallbackURL == nil { fallbackURL = valueURL }
            case "primaryTrackingUrl":
                if primaryTrackingURLs == nil { primaryTrackingURLs = [] }
                primaryTrackingURLs?.append(valueURL)
            case "fallbackTrackingUrl":
                if fallbackTrackingURLs == nil { fallbackTrackingURLs = [] }
                fallbackTrackingURLs?.append(valueURL)
            default:
                break
            }
        }

        guard let primary = primaryURL else { return nil }
        return DeepLinkPlus(primaryURL: primary,
                            fallbackURL: fallbackURL,
                            primaryTrackingURLs: primaryTrackingURLs,
                            fallbackTrackingURLs: fallbackTrackingURLs)
    }

    // Inline of NSURL+PBMExtensions PBMURLWithoutEncodingFromString: (Gap 8 pattern)
    private static func urlWithoutEncoding(from string: String?) -> URL? {
        guard let str = string else { return nil }
        if #available(iOS 17.0, *) {
            return URL(string: str, encodingInvalidCharacters: false)
        } else {
            return URL(string: str)
        }
    }
}
