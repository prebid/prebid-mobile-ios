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

import UIKit

public class NativeEventTracker: NSObject {
    
    var event: EventType
    var methods: Array<EventTracking>
    var ext: AnyObject?
    
    public init(event: EventType, methods: Array<EventTracking>) {
        self.event = event
        self.methods = methods
    }
    
    func getEventTracker() -> [AnyHashable: Any] {
        var methodsList:[Int] = []
        
        for method:EventTracking in methods {
            methodsList.append(method.rawValue)
        }
        
        let event = [
            "event": self.event.exchangeID,
            "methods": methodsList
            ] as [String : Any]
        
        return event
    }
}

@objc public enum EventType:Int {

    case Impression = 1
    case ViewableImpression50 = 2
    case ViewableImpression100 = 3
    case ViewableVideoImpression50 = 4
    case Custom
    
    private static var customValue = 500
    
    public var exchangeID:Int {
        get {
            switch self {
            case .Custom:
                return EventType.customValue
            default:
                return self.rawValue
            }
        }
        set {
            EventType.customValue = newValue
        }
        
    }
}

@objc public enum EventTracking: Int {
    case Image = 1
    case js = 2
    case Custom
    
    private static var customValue = 500
    
    public var exchangeID:Int {
        get {
            switch self {
            case .Custom:
                return EventTracking.customValue
            default:
                return self.rawValue
            }
        }
        set {
            EventTracking.customValue = newValue
        }
        
    }
}




