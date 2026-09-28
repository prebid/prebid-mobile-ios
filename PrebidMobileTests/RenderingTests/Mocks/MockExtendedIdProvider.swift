/*   Copyright 2018-2026 Prebid.org, Inc.

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
@testable import PrebidMobile

final class MockExtendedIdProvider: NSObject, ExtendedIdProvider {

    let providerInfo: ExtendedIdProviderInfo

    var extendedIds: [ExtendedId]

    var onRegisterHandler: (() -> Void)?

    private(set) var getExtendedIdsCount = 0
    private(set) var onRegisterCount = 0
    private(set) var onUnregisterCount = 0

    init(name: String, version: String = "1.0", extendedIds: [ExtendedId] = []) {
        self.providerInfo = ExtendedIdProviderInfo(name: name, version: version)
        self.extendedIds = extendedIds
    }

    func getExtendedIds() -> [ExtendedId] {
        getExtendedIdsCount += 1
        return extendedIds
    }

    func onRegister() {
        onRegisterCount += 1
        onRegisterHandler?()
    }

    func onUnregister() {
        onUnregisterCount += 1
    }
}

/// Implements only the required members, leaving out `onRegister()` and `onUnregister()`.
final class MockMinimalExtendedIdProvider: NSObject, ExtendedIdProvider {

    let providerInfo: ExtendedIdProviderInfo

    private let extendedIds: [ExtendedId]

    init(name: String, extendedIds: [ExtendedId]) {
        self.providerInfo = ExtendedIdProviderInfo(name: name, version: "1.0")
        self.extendedIds = extendedIds
    }

    func getExtendedIds() -> [ExtendedId] {
        extendedIds
    }
}

/// An `ExtendedId` whose JSON `JSONSerialization` can't encode.
final class MockInvalidExtendedId: NSObject, ExtendedId {

    let source = "invalid.com"

    func toJSONDictionary() -> [String: Any] {
        ["source": source, "uids": [["id": Date(), "atype": 1]]]
    }
}
