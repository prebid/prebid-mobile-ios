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

    public var parameters: Parameters?

    //MARK: - Parameters class
    
    /// Describes an [OpenRTB](https://www.iab.com/wp-content/uploads/2016/03/OpenRTB-API-Specification-Version-2-5-FINAL.pdf) video object
    @objc(PBVideoAdUnitParameters)
    public class Parameters: NSObject {
        
        /// List of supported API frameworks for this impression. If an API is not explicitly listed, it is assumed not to be supported.
        @objc
        public var api: [Signals.Api]?

        /// Maximum bit rate in Kbps.
        @objc
        public var maxBitrate: Signals.SingleContainerInt?
        
        /// Maximum bit rate in Kbps.
        @objc
        public var minBitrate: Signals.SingleContainerInt?
        
        /// Maximum video ad duration in seconds.
        @objc
        public var maxDuration: Signals.SingleContainerInt?
        

        /// Minimum video ad duration in seconds.
        @objc
        public var minDuration: Signals.SingleContainerInt?
        
        /**
        Content MIME types supported
        
        # Example #
        * "video/mp4"
        * "video/x-ms-wmv"
        */
        @objc
        public var mimes: [String]?
        
        /// Allowed playback methods. If none specified, assume all are allowed.
        @objc
        public var playbackMethod: [Signals.PlaybackMethod]?
        
        /// Array of supported video bid response protocols.
        @objc
        public var protocols: [Signals.Protocols]?
        
        /// Indicates the start delay in seconds for pre-roll, mid-roll, or post-roll ad placements.
        @objc
        public var startDelay: Signals.StartDelay?
        
        /// Placement type for the impression.
        @objc
        public var placement: Signals.Placement?
        
    }
}
