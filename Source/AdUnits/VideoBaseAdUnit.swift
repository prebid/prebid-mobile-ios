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
        
        /**
        List of supported API frameworks for this impression. If an API is not explicitly listed, it is assumed not to be supported.

        # Example #
        ```
        | Value | Description |
        |-------|-------------|
        | 1     | VPAID 1.0   |
        | 2     | VPAID 2.0   |
        | 3     | VPAID 2.0   |
        | 4     | ORMMA       |
        | 5     | MRAID-2     |
        ```
        */
        public var api: [Int]?

        /**
        Maximum bit rate in Kbps.
        */
        public var maxBitrate: Int?
        
        /**
        Maximum bit rate in Kbps.
        */
        public var minBitrate: Int?
        
        /**
        Maximum video ad duration in seconds.
        */
        public var maxDuration: Int?
        
        /**
        Minimum video ad duration in seconds.
        */
        public var minDuration: Int?
        
        /**
        Content MIME types supported
        
        # Example #
        * "video/mp4"
        * "video/x-ms-wmv"
        */
        public var mimes: [String]?
        
        /**
        Allowed playback methods. If none specified, assume all are allowed.

        # Example #
        ```
        | Value | Description         |
        |-------|---------------------|
        | 1     | Auto-Play Sound On  |
        | 2     | Auto-Play Sound Off |
        | 3     | Click-to-Play       |
        | 4     | Mouse-Over          |
        ```
        */
        public var playbackMethod: [Int]?
        
        /**
        Array of supported video bid response protocols.

        # Example #
        ```
        | Value | Description      |
        |-------|------------------|
        | 1     | VAST 1.0         |
        | 2     | VAST 2.0         |
        | 3     | VAST 3.0         |
        | 4     | VAST 1.0 Wrapper |
        | 5     | VAST 2.0 Wrapper |
        | 6     | VAST 3.0 Wrapper |
        ```
        */
        public var protocols: [Int]?
        
        /**
        Indicates the start delay in seconds for pre-roll, mid-roll, or post-roll ad placements.

        # Example #
        ```
        | Value | Description                                      |
        |-------|--------------------------------------------------|
        | > 0   | Mid-Roll (value indicates start delay in second) |
        | 0     | Pre-Roll                                         |
        | -1    | Generic Mid-Roll                                 |
        | -2    | Generic Post-Roll                                |
        ```
        */
        public var startDelay: Int?
        
        public init() {}
        
    }
}




