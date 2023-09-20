/*   Copyright 2018-2021 Prebid.org, Inc.

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

@objc(PBMAutoRefreshCountConfig) @objcMembers
public class AutoRefreshCountConfig: NSObject {
    
    /**
     Delay (in seconds) for which to wait before performing an auto refresh.

     Note that this value is clamped between @c PBMAutoRefresh.AUTO_REFRESH_DELAY_MIN
     and @c PBMAutoRefresh.AUTO_REFRESH_DELAY_MAX.

     Also note that this will return @c nil if @c isInterstitial is set to @c YES.
     */
    public var autoRefreshDelay: TimeInterval? 
    
    /**
     Maximum number of times the BannerView should refresh.

     This value will be overwritten with any values received from the server.
     Using a value of 0 indicates there is no maximum.

     Default is 0.
     */
    public var autoRefreshMax: Double?  = 0
    
    /**
     The number of times the BannerView has been refreshed.
     */
    public var numRefreshes = 0
}
