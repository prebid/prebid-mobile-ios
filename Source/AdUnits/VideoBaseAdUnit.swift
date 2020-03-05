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


public class VideoBaseAdUnit: AdUnit {

    public var videoParameters: VideoParameters?

    //MARK: - VideoParameters class
    
    /// Describes an [OpenRTB](https://www.iab.com/wp-content/uploads/2016/03/OpenRTB-API-Specification-Version-2-5-FINAL.pdf) video object
    public class VideoParameters {
        
        public var api: [Int]?
        public var maxBitrate: Int?
        public var minBitrate: Int?
        public var maxDuration: Int?
        public var minDuration: Int?
        public var mimes: [String]?
        public var playbackMethod: [Int]?
        public var protocols: [Int]?
        public var startDelay: Int?
        
        public init() {}
        
    }
}




