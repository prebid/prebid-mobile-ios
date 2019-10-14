//
//  EventTrackers.swift
//  PrebidMobile
//
//  Created by Punnaghai Puviarasu on 10/14/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import UIKit

public class NativeEventTracker: NSObject {
    
    var event:EventType?
    var methods:Array<EventTracking>?
    var ext:AnyObject?
    
    required public init(event:EventType, methods:Array<EventTracking>) {
        super.init()
        self.event = event
        self.methods = methods
    }
    
    func getEventTracker() -> [AnyHashable: Any] {
        let event = [
            "event": self.event!,
            "methods": self.methods!
            ] as [String : Any]
        return event
    }
}

@objc public enum EventType: Int {
    case Impression = 1
    case ViewableImpression50 = 2
    case ViewableImpression100 = 3
    case ViewableVideoImpression50 = 4
    case TBD = 500
}

@objc public enum EventTracking: Int {
    case Image = 1
    case js = 2
    case TBD = 500
}
