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

/// Represents parameters for a native ad request, including assets, event trackers, and configuration settings.
@objcMembers
public class NativeParameters: NSObject {
    
    /// An array of `NativeAsset` objects representing the assets required for the native ad request.
    public var assets: [NativeAsset]?
    
    /// An array of `NativeEventTracker` objects specifying the event tracking settings for the native ad.
    public var eventtrackers: [NativeEventTracker]?
    
    /// The version of the native ad specification being used. Defaults to "1.2".
    public var version: String = "1.2"
    
    /// The context in which the ad appears. See `ContextType` for possible values.
    public var context: ContextType?
    
    /// A more detailed context in which the ad appears. See `ContextSubType` for possible values.
    public var contextSubType: ContextSubType?
    
    /// The design/format/layout of the ad unit being offered. See `PlacementType` for possible values.
    public var placementType: PlacementType?
    
    /// The number of identical placements in the ad layout. Defaults to 1.
    public var placementCount: Int = 1
    
    /// The sequence number of the ad. Defaults to 0.
    public var sequence: Int = 0
    
    /// Indicates whether the supply source/impression supports returning an `assetsurl` instead of an asset object.
    /// Defaults to 0, indicating no support.
    public var asseturlsupport: Int = 0
    
    /// Indicates whether the supply source/impression supports returning a `dco` URL instead of an asset object.
    /// Defaults to 0, indicating no support.
    public var durlsupport: Int = 0
    
    /// Indicates whether the supply source/impression supports returning a `dco` URL instead of an asset object.
    /// Defaults to 0, indicating no support.
    public var privacy: Int = 0
    
    /// A placeholder for custom JSON agreed to by the parties to support flexibility beyond the standard specification.
    public var ext: [String: Any]?
}
