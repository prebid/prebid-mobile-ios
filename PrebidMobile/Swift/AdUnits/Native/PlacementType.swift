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

/// Represents different types of placements for native ads.
@objcMembers
public class PlacementType: SingleContainerInt {
    
    /// Placement type indicating the ad appears within feed content.
    public static let FeedContent = PlacementType(1)
    
    /// Placement type indicating the ad appears within atomic content.
    public static let AtomicContent = PlacementType(2)
    
    /// Placement type indicating the ad appears outside of content.
    public static let OutsideContent = PlacementType(3)
    
    /// Placement type indicating the ad appears within a recommendation widget.
    public static let RecommendationWidget = PlacementType(4)
    
    /// Placement type for custom placements not predefined in the standard.
    public static let Custom = PlacementType(500)
}
