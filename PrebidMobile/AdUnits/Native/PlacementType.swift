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

@objcMembers
public class PlacementType: SingleContainerInt {

    public static let FeedContent = PlacementType(1)

    public static let AtomicContent = PlacementType(2)

    public static let OutsideContent = PlacementType(3)

    public static let RecommendationWidget = PlacementType(4)

    public static let Custom = PlacementType(500)
}
