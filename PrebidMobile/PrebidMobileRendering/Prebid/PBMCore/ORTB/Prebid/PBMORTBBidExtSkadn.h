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
#import "PBMORTBSkadnFidelity.h"

NS_ASSUME_NONNULL_BEGIN

//https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md

@interface PBMORTBBidExtSkadn : PBMORTBAbstract

// Version of SKAdNetwork desired. Must be 2.0 or above
@property (nonatomic, copy, nullable) NSString *version;
// Ad network identifier used in signature
@property (nonatomic, copy, nullable) NSString *network;
// Campaign ID compatible with Apple’s spec
@property (nonatomic, copy, nullable) NSNumber *campaign;
// ID of advertiser’s app in Apple’s app store
@property (nonatomic, copy, nullable) NSNumber *itunesitem;
// ID of publisher’s app in Apple’s app store
@property (nonatomic, copy, nullable) NSNumber *sourceapp;
// Supports multiple fidelity types introduced in SKAdNetwork v2.2
@property (nonatomic, copy, nullable) NSArray<PBMORTBSkadnFidelity *>  *fidelities;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext object not supported.

@end


NS_ASSUME_NONNULL_END
