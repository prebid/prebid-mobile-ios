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

/// The static EIDs set through `Targeting.addExternalUserId(_:)` and `Targeting.setExternalUserIds(_:)`.
///
/// Each change is applied under a lock, so a bid request never sees a partly updated list.
final class StaticExtendedIdProvider {

    private let lock = NSLock()
    private var userIds = [ExternalUserId]()

    /// The static IDs, in the order they were set.
    var externalUserIds: [ExternalUserId] {
        synchronized { userIds }
    }

    func getExtendedIds() -> [ExtendedId] {
        externalUserIds
    }

    /// Replaces all static IDs with `newUserIds`.
    func setUserIds(_ newUserIds: [ExternalUserId]) {
        synchronized { userIds = newUserIds }
    }

    /// Adds `userId`, replacing the IDs that have the same source.
    func addUserId(_ userId: ExternalUserId) {
        synchronized {
            userIds.removeAll { $0.source == userId.source }
            userIds.append(userId)
        }
    }

    /// Removes the IDs with the given source.
    func removeUserId(source: String) {
        synchronized {
            userIds.removeAll { $0.source == source }
        }
    }

    func clear() {
        synchronized { userIds.removeAll() }
    }

    private func synchronized<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
