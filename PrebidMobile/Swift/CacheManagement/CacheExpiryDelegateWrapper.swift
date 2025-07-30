/*   Copyright 2019-2023 Prebid.org, Inc.

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

/// Wrapper that is used for `CacheExpiryDelegate`  storage in `CacheManager`
class CacheExpiryDelegateWrapper {
    
    var id: String
    weak var delegate: CacheExpiryDelegate?
    
    init(id: String, delegate: CacheExpiryDelegate? = nil) {
        self.id = id
        self.delegate = delegate
    }
}
