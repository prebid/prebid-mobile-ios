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

//This object includes signals necessary for support SKAdNetwork
//https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md
@interface PBMORTBImpExtSkadn : PBMORTBAbstract

// ID of publisher app in Apple’s App Store.
@property (nonatomic, copy, nullable) NSString *sourceapp;

//A subset of SKAdNetworkItem entries in the publisher app’s Info.plist that are relevant to the DSP.
@property (nonatomic, copy, nullable) NSArray<NSString *> *skadnetids;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext object is not supported.

- (instancetype )init;

@end

NS_ASSUME_NONNULL_END
