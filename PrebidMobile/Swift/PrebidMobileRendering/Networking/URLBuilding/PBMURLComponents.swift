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

    private let nsUrlComponents: NSURLComponents

    @objc(initWithUrl:paramsDict:)
    public init?(url: String, paramsDict: [String: String]) {
        guard let urlComponents = NSURLComponents(string: url) else {
            return nil
        }

        // Convert existing query items to a mutable list.
        var queryItems = urlComponents.queryItems ?? []

        // Add query items from paramsDict. This may result in some keys appearing twice.
        for key in paramsDict.keys.sorted() {
            queryItems.append(URLQueryItem(name: key, value: paramsDict[key]))
        }

        // Remove dupes. Items added later have higher precedence, so we reverse the list first.
        queryItems.reverse()

        // If the accumulator array contains an item that has the same name,
        // ignore the current item we are examining.
        // Otherwise, append the item we are examining to the accumulator.
        var filteredItems: [URLQueryItem] = []
        for item in queryItems where !filteredItems.contains(where: { $0.name == item.name }) {
            filteredItems.append(item)
        }

        filteredItems.reverse()
        urlComponents.queryItems = filteredItems
        self.nsUrlComponents = urlComponents

        super.init()
    }

    @objc public var fullURL: String {
        nsUrlComponents.string ?? ""
    }

    @objc public var urlString: String {
        nsUrlComponents.string?.PBMsubstringToString("?") ?? nsUrlComponents.string ?? ""
    }

    @objc public var argumentsString: String {
        nsUrlComponents.percentEncodedQuery ?? ""
    }
}
