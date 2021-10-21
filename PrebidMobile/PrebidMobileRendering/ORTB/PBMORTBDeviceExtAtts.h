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

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

// If the IDFA is not available, DSPs require an alternative, limited-scope identifier in order to
//provide basic frequency capping functionality to advertisers
// https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md#device-extension

@interface PBMORTBDeviceExtAtts : PBMORTBAbstract

// An integer passed to represent the app's app tracking authorization status, where
//0 = not determined
//1 = restricted
//2 = denied
//3 = authorized
@property (nonatomic, strong, nullable) NSNumber *atts;

//IDFV of the device in that publisher. Only passed when IDFA (BidRequest.device.ifa) is unavailable or all zeros
@property (nonatomic, copy, nullable) NSString *ifv;
@end

NS_ASSUME_NONNULL_END
