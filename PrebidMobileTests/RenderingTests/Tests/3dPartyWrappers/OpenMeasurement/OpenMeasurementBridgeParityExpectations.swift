/*   Copyright 2018-2025 Prebid.org, Inc.

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

/// Output of the Objective-C `PBMOpenMeasurementFriendlyObstructionTypeBridge` (both class methods) for every
/// `PBMOpenMeasurementFriendlyObstructionPurpose` value plus out-of-range raw values, captured before the class was
/// ported. `nil` and `""` print differently. `type` is the raw value of `OMIDFriendlyObstructionType`
/// (0 mediaControls, 1 closeAd, 2 notVisible, 3 other). Raw values 6 and above have no Swift enum case
/// (6 is `purposesCount`), so `desc=nil` for them is the ObjC `default:` branch.
enum OpenMeasurementBridgeParityExpectations {
    static let expected = """
0 type=3 desc="Fullscreen UI locker or loading the ad"
1 type=3 desc="Activity Indicator for loading the ad"
2 type=3 desc="Fullscreen modal ad view container"
3 type=1 desc="Close button"
4 type=3 desc="Learn More  button"
5 type=0 desc="Video playback Progress Bar"
6 type=3 desc=nil
7 type=3 desc=nil
8 type=3 desc=nil
99 type=3 desc=nil
18446744073709551615 type=3 desc=nil
"""
}
