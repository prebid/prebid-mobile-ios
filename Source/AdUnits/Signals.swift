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


public class SingleContainerInt: NSObject, ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = Int
    
    @objc
    public let value: Int
    
    @objc
    public required init(integerLiteral value: Int) {
        self.value = value
    }
    
    static func == (lhs: SingleContainerInt, rhs: SingleContainerInt) -> Bool {
        return lhs.value == rhs.value
    }

    override public func isEqual(_ object: Any?) -> Bool {

        if let other = object as? SingleContainerInt {
            if self === other {
                return true
            } else {
                return self.value == other.value
            }
        }

        return false

    }

    override public var hash : Int {
        return value.hashValue
    }
}
/**
 # OpenRTB - API Frameworks #
 ```
 | Value | Description |
 |-------|-------------|
 | 1     | VPAID 1.0   |
 | 2     | VPAID 2.0   |
 | 3     | MRAID-1     |
 | 4     | ORMMA       |
 | 5     | MRAID-2     |
 | 6     | MRAID-3     |
 ```
 */
@objc(PBApi)
public class Api: SingleContainerInt {
    
    /// VPAID 1.0
    @objc
    public static let VPAID_1 = Api(1)
    
    /// VPAID 2.0
    @objc
    public static let VPAID_2 = Api(2)
    
    /// MRAID-1
    @objc
    public static let MRAID_1 = Api(3)
    
    /// ORMMA
    @objc
    public static let ORMMA = Api(4)
    
    /// MRAID-2
    @objc
    public static let MARAID_2 = Api(5)
    
    /// MRAID-3
    @objc
    public static let MARAID_3 = Api(6)
}

/**
# OpenRTB - Playback Methods #
```
| Value | Description                                              |
|-------|----------------------------------------------------------|
| 1     | Initiates on Page Load with Sound On                     |
| 2     | Initiates on Page Load with Sound Off by Default         |
| 3     | Initiates on Click with Sound On                         |
| 4     | Initiates on Mouse-Over with Sound On                    |
| 5     | Initiates on Entering Viewport with Sound On             |
| 6     | Initiates on Entering Viewport with Sound Off by Default |
```
*/
@objc(PBPlaybackMethod)
public class PlaybackMethod: SingleContainerInt {

    /// Initiates on Page Load with Sound On
    @objc
    public static let AutoPlaySoundOn = PlaybackMethod(1)
    
    /// Initiates on Page Load with Sound Off by Default
    @objc
    public static let AutoPlaySoundOff = PlaybackMethod(2)
    
    /// Initiates on Click with Sound On
    @objc
    public static let ClickToPlay = PlaybackMethod(3)
    
    /// Initiates on Mouse-Over with Sound On
    @objc
    public static let MouseOver = PlaybackMethod(4)
    
    /// Initiates on Entering Viewport with Sound On
    @objc
    public static let EnterSoundOn = PlaybackMethod(5)
    
    /// Initiates on Entering Viewport with Sound Off by Default
    @objc
    public static let EnterSoundOff = PlaybackMethod(6)

}

/**
# OpenRTB - Protocols #
```
| Value | Description       |
|-------|-------------------|
| 1     | VAST 1.0          |
| 2     | VAST 2.0          |
| 3     | VAST 3.0          |
| 4     | VAST 1.0 Wrapper  |
| 5     | VAST 2.0 Wrapper  |
| 6     | VAST 3.0 Wrapper  |
| 7     | VAST 4.0          |
| 8     | VAST 4.0 Wrapper  |
| 9     | DAAST 1.0         |
| 10    | DAAST 1.0 Wrapper |
```
*/
@objc(PBProtocols)
public class Protocols: SingleContainerInt {
    
    /// VAST 1.0
    @objc
    public static let VAST_1_0 = Protocols(1)
    
    /// VAST 2.0
    @objc
    public static let VAST_2_0 = Protocols(2)
    
    /// VAST 3.0
    @objc
    public static let VAST_3_0 = Protocols(3)
    
    /// VAST 1.0 Wrapper
    @objc
    public static let VAST_1_0_Wrapper = Protocols(4)
    
    /// VAST 2.0 Wrapper
    @objc
    public static let VAST_2_0_Wrapper = Protocols(5)
    
    /// VAST 3.0 Wrapper
    @objc
    public static let VAST_3_0_Wrapper = Protocols(6)
    
    /// VAST 4.0
    @objc
    public static let VAST_4_0 = Protocols(7)
    
    /// VAST 4.0 Wrapper
    @objc
    public static let VAST_4_0_Wrapper = Protocols(8)
    
    /// DAAST 1.0
    @objc
    public static let DAAST_1_0 = Protocols(9)
    
    /// DAAST 1.0 Wrapper
    @objc
    public static let DAAST_1_0_WRAPPER = Protocols(10)
    
}

/**
# OpenRTB - Start Delay #
```
| Value | Description                                      |
|-------|--------------------------------------------------|
| > 0   | Mid-Roll (value indicates start delay in second) |
| 0     | Pre-Roll                                         |
| -1    | Generic Mid-Roll                                 |
| -2    | Generic Post-Roll                                |
```
*/
@objc(PBStartDelay)
public class StartDelay: SingleContainerInt {
    
    /// Pre-Roll
    @objc
    public static let PreRoll = StartDelay(0)
    
    /// Generic Mid-Roll
    @objc
    public static let GenericMidRoll = StartDelay(-1)
    
    /// Generic Post-Roll
    @objc
    public static let GenericPostRoll = StartDelay(-2)
    
}
