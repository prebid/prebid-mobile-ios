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

/// Enum representing various positions on the screen.
///
/// This enum defines positions that can be used for placing elements within an ad. The positions are typically used to determine where controls or components should be located within the ad's user interface.
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
    
    /// Returns the corresponding `Position` enum value for a given string literal.
    ///
    /// - Parameter stringValue: A string representing the position.
    /// - Returns: The `Position` enum value if it matches one of the predefined cases; otherwise, returns `nil`.
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
