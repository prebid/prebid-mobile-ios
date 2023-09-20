/*   Copyright 2018-2021 Prebid.org, Inc.

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

@objc(PBMPosition)
public enum Position: Int {
    case undefined = -1
    case topLeft
    case topCenter
    case topRight
    case center
    case bottomLeft
    case bottomCenter
    case bottomRight
    case custom
    
    public static func getPositionByStringLiteral(_ stringValue: String) -> Position? {
        switch stringValue {
        case "topleft":
            return .topLeft
        case "topright":
            return .topRight
        default:
            return nil
        }
    }
}
