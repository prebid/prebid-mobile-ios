//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation


@objc(PBMVastTrackingEvents) @_spi(PBMInternal) public
class VastTrackingEvents: NSObject {
    
    @objc public internal(set) var trackingEvents = [String : [String]]()
    @objc public internal(set) var progressOffsets = [NSNumber]()
    
    @objc public func addTrackingURL(_ url: String?,
                             event: String?,
                             attributes: [String : String]?) {
        guard let url, let event else {
            return
        }
        
        var urlsForEvent = trackingEvents[event] ?? []
        urlsForEvent.append(url)
        trackingEvents[event] = urlsForEvent
        
        // if it is a progress event add the offset attribute to progressOffsets
        // TODO: the progress events need to be sorted by offset it is not required for them to be listed in chronological order
        if event == "progress", let attributes {
            progressOffsets.append((attributes["offset"].flatMap { Double($0) } ?? 0) as NSNumber)
        }
    }
    
    @objc public func trackingURLs(forEvent event: String?) -> [String]? {
        event.flatMap { trackingEvents[$0] }
    }
    
    
    @objc public func addTrackingEvents(_ events: VastTrackingEvents?) {
        guard let events else {
            return
        }
        
        events.trackingEvents.forEach { event, urlArray in
            for url in urlArray {
                addTrackingURL(url, event: event, attributes: nil)
            }
        }
    }
}
