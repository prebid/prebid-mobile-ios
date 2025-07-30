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

/// Ad position on screen. Refer to List 5.4:
/// The following table specifies the position of the ad as a relative measure of visibility or prominence. This
/// OpenRTB table has values derived from the Inventory Quality Guidelines (IQG). Practitioners should
/// keep in sync with updates to the IQG values as published on IAB.com. Values “4” - “7” apply to apps per
/// the mobile addendum to IQG version 2.1.
/// Value Description
/// 0 Unknown
/// 1 Above the Fold
/// 2 DEPRECATED - May or may not be initially visible depending on screen size/resolution.
/// 3 Below the Fold
/// 4 Header
/// 5 Footer
/// 6 Sidebar
/// 7 Full Screen
@objc(PBMAdPosition)
public enum AdPosition: Int {
    
    /// 0 Unknown
    case undefined = 0
    
    /// 1 Above the Fold
    case aboveTheFold = 1
    
    /// 2 Locked (i.e. fixed position)
    case locked = 2
    
    /// 3 Below the Fold
    case belowTheFold = 3
    
    /// 4 Header
    case header = 4
    
    /// 5 Footer
    case footer = 5
    
    /// 6 Sidebar
    case sidebar = 6
    
    /// 7 Full Screen
    case fullScreen = 7
}
