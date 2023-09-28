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

@objcMembers
public class NativeParameters: NSObject {
    
    public var assets: [NativeAsset]?
    public var eventtrackers: [NativeEventTracker]?
    
    public var version: String = "1.2"
    public var context: ContextType?
    public var contextSubType: ContextSubType?
    public var placementType: PlacementType?
    public var placementCount: Int = 1
    public var sequence: Int = 0
    
    public var asseturlsupport: Int = 0
    public var durlsupport: Int = 0
    
    public var privacy: Int = 0
    public var ext: [String: Any]?
}
