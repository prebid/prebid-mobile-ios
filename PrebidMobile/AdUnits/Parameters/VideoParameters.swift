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

/// Describes an [OpenRTB](https://www.iab.com/wp-content/uploads/2016/03/OpenRTB-API-Specification-Version-2-5-FINAL.pdf) video object
@objcMembers
public class VideoParameters: NSObject {
    
    /// List of supported API frameworks for this impression. If an API is not explicitly listed, it is assumed not to be supported.
    public var api: [Signals.Api]?
    
    /// Maximum bit rate in Kbps.
    public var maxBitrate: SingleContainerInt?
    
    /// Maximum bit rate in Kbps.
    public var minBitrate: SingleContainerInt?
    
    /// Maximum video ad duration in seconds.
    public var maxDuration: SingleContainerInt?
    
    /// Minimum video ad duration in seconds.
    public var minDuration: SingleContainerInt?
    
    
    /// Content MIME types supported.
    /// Prebid Server required property.
     
    /// # Example #
    /// "video/mp4"
    /// "video/x-ms-wmv"
    ///
    public var mimes: [String]
    
    /// Allowed playback methods. If none specified, assume all are allowed.
    public var playbackMethod: [Signals.PlaybackMethod]?
    
    /// Array of supported video bid response protocols.
    public var protocols: [Signals.Protocols]?
    
    /// Indicates the start delay in seconds for pre-roll, mid-roll, or post-roll ad placements.
    public var startDelay: Signals.StartDelay?
    
    /// Placement type for the impression.
    public var placement: Signals.Placement?
    
    /// Placement type for the impression.
    public var plcmnt: Signals.Plcmnt?
    
    /// Indicates if the impression must be linear, nonlinear, etc. If none specified, assume all are allowed.
    public var linearity: SingleContainerInt?
    
    public var adSize: CGSize?
    
    // MARK: - Helpers
    
    /// Helper property
    public var rawAPI: [Int]? {
        get {
            api?.toIntArray()
        }
    }
    
    /// Helper property
    public var rawPlaybackMethod: [Int]? {
        get {
            playbackMethod?.toIntArray()
        }
    }
    
    /// Helper property
    public var rawProtocols: [Int]? {
        get {
            protocols?.toIntArray()
        }
    }
    
    /// - Parameter mimes: supported MIME types
    public init(mimes: [String]) {
        self.mimes = mimes
    }
    
    ///  Objective-C API
    public func setSize(_ size: NSValue) {
        adSize = size.cgSizeValue
    }
}
