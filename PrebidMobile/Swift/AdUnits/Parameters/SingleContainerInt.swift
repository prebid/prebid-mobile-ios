/*   Copyright 2018-2019 Prebid.org, Inc.

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

public class SingleContainerInt: NSObject, ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = Int
    
    @objc
    public let value: Int
    
    @objc
    public required init(integerLiteral value: Int) {
        self.value = value
    }
    
    static func == (lhs: SingleContainerInt, rhs: SingleContainerInt) -> Bool {
        return lhs.value == rhs.value
    }

    override public func isEqual(_ object: Any?) -> Bool {

        if let other = object as? SingleContainerInt {
            if self === other {
                return true
            } else {
                return self.value == other.value
            }
        }

        return false

    }

    override public var hash: Int {
        return value.hashValue
    }
}
