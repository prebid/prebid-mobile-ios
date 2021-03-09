/*   Copyright 2020-2021 Prebid.org, Inc.

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

import UIKit

/**
 Defines the User Id Object from an External Thrid Party Source
 */
@objcMembers public class ExternalUserId: NSObject {
    // MARK: - Properties
    /**
     Source of the External User Id String
     */
    var source: String
    /**
     Array of Dictionaries containing objects that hold UserId parameters.
     */
    var userIdArray: [[String: Any]]

    // MARK: - Initialization
    /**
     Initialize ExternalUserId Class
    - Parameter source: Source of the External User Id String.
    - Parameter userIdArray: Array of Dictionaries containing objects that hold UserId parameters.
    */
    public init(source:String, userIdArray:[[String: Any]]) {
        self.source = source
        self.userIdArray = userIdArray
    }
}
