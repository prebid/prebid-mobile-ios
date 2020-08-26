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

@objc public class NativeEventTracker: NSObject {
    
    var event: EventType
    var methods: Array<EventTracking>
    var ext: AnyObject?
    
    @objc
    public init(event: EventType, methods: Array<EventTracking>) {
        self.event = event
        self.methods = methods
    }
    
    func getEventTracker() -> [AnyHashable: Any] {
        var methodsList:[Int] = []
        
        for method:EventTracking in methods {
            methodsList.append(method.value)
        }
        
        let event = [
            "event": self.event.value,
            "methods": methodsList
            ] as [String : Any]
        
        return event
    }
}

public class EventType: SingleContainerInt {
    @objc
    public static let Impression = EventType(1)

    @objc
    public static let ViewableImpression50 = EventType(2)

    @objc
    public static let ViewableImpression100 = EventType(3)

    @objc
    public static let ViewableVideoImpression50 = EventType(4)

    @objc
    public static let Custom = EventType(500)
}


public class EventTracking: SingleContainerInt {
    @objc
    public static let Image = EventTracking(1)

    @objc
    public static let js = EventTracking(2)

    @objc
    public static let Custom = EventTracking(500)
}
