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

extension NSMutableDictionary {

    @objc public func pbmRemoveEmptyVals() {
        for key in allKeys {
            if isEmptyVal(self[key]) {
                removeObject(forKey: key)
            }
        }
    }

    @objc public func pbmCopyWithoutEmptyVals() -> NSMutableDictionary {
        let result = NSMutableDictionary()
        for key in allKeys {
            if let value = self[key], !isEmptyVal(value) {
                result[key] = value
            }
        }
        return result
    }

    /// Mirrors the Objective-C `dict[key] = value` semantics, where assigning `nil` removes the key.
    /// A plain Swift subscript assignment would instead store a boxed `Optional.none`.
    func pbmSetValue(_ value: Any?, forKey key: String) {
        if let value = value {
            self[key] = value
        } else {
            removeObject(forKey: key)
        }
    }
}

private func isEmptyVal(_ value: Any?) -> Bool {
    value == nil || value is NSNull
}
