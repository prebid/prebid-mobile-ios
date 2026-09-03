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

// Named `PBMURLComponents`, not `URLComponents` — Foundation already defines
// `URLComponents`, and this type is still constructed from ObjC (`PBMVastRequester.m`).
@objc(PBMURLComponents)
public class PBMURLComponents: NSObject {

    private let urlComponents: URLComponents

    // `url`/`paramsDict` stay Optional even though the deleted ObjC header declared them
    // `NS_ASSUME_NONNULL` — that annotation is compile-time only, and this initializer is
    // `public`/`@objc`, so a future ObjC caller that passes `nil` must get `nil` back
    // gracefully (matching `PBMURLComponents.m`'s `if (!urlComponents || !paramsDict)`)
    // instead of trapping during Swift/ObjC bridging.
    @objc(initWithUrl:paramsDict:)
    public init?(url: String?, paramsDict: [String: String]?) {
        guard let url = url, let paramsDict = paramsDict,
              var components = URLComponents(string: url) else {
            Log.error("Failed to create PBMURLComponents: invalid url or paramsDict")
            return nil
        }

        var queryItems = components.queryItems ?? []

        // Add query items from paramsDict. This may result in some keys appearing twice.
        for key in paramsDict.keys.sorted() {
            queryItems.append(URLQueryItem(name: key, value: paramsDict[key]))
        }

        // Keep the last occurrence of each name — a paramsDict key beats an existing
        // query-string key with the same name — while leaving the surviving items in
        // their original relative order. Compared as `NSString` (literal UTF-16
        // comparison) rather than Swift's `==` (Unicode canonical-equivalence
        // comparison), so two names that are the same grapheme cluster under different
        // Unicode normalization forms are still treated as distinct, matching ObjC's
        // `isEqualToString:`.
        var lastIndexByName: [NSString: Int] = [:]
        for (index, item) in queryItems.enumerated() {
            lastIndexByName[item.name as NSString] = index
        }
        queryItems = queryItems.enumerated()
            .filter { lastIndexByName[$0.element.name as NSString] == $0.offset }
            .map { $0.element }

        components.queryItems = queryItems
        self.urlComponents = components

        super.init()
    }

    @objc public var fullURL: String {
        urlComponents.string ?? ""
    }

    @objc public var urlString: String {
        let fullURLString = urlComponents.string
        return fullURLString?.PBMsubstringToString("?") ?? fullURLString ?? ""
    }

    @objc public var argumentsString: String {
        urlComponents.percentEncodedQuery ?? ""
    }
}
