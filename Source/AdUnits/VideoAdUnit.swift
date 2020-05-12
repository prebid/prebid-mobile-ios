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

public class VideoAdUnit: VideoBaseAdUnit {

    @available(iOS, deprecated)
    var type: PlacementType?

    public init(configId: String, size: CGSize) {
        super.init(configId: configId, size: size)
    }
    
    @available(iOS, deprecated, message: "Replaced by VideoAdUnit(String, int, int)")
    public init(configId: String, size: CGSize, type: PlacementType) {
        self.type = type
        super.init(configId: configId, size: size)
    }

    public func addAdditionalSize(sizes: [CGSize]) {
        super.adSizes += sizes
    }

    @available(iOS, deprecated, message: "Replaced by Signals.Placement")
    @objc(PBVideoPlacementType)
    public enum PlacementType: Int {
        @available(iOS, deprecated)
        case inBanner = 2
        
        @available(iOS, deprecated)
        case inArticle = 3
        
        @available(iOS, deprecated)
        case inFeed = 4
    }

}
