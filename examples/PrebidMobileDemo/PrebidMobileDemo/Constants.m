/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "Constants.h"
#import <PrebidMobile/PBHost.h>

@implementation Constants

NSString *const kAdServer = @"Ad Server";
NSString *const kAdType = @"Ad Type";
NSString *const kPlacementId = @"Placement ID";
NSString *const kSize = @"Size";

NSString *const kGDPRString = @"gdprConsentString";

NSString *const kDefaultPlacementId = @"9373413";
NSString *const kDefaultSize = @"300x250";

NSString *const kBanner = @"Banner";
NSString *const kInterstitial = @"Interstitial";
NSString *const kNative = @"Native";
NSString *const kVideo = @"Video";

#pragma mark - MoPub constants
NSString *const kMoPubAdServer = @"MoPub";
NSString *const kMoPubBannerAdUnitId = @"bd0a2cd5dd2241aaac18d7823d8e3a6f";
NSString *const kMoPubInterstitialAdUnitId = @"af48b6575ff34fbf9337dc099f4b6032";

#pragma mark - DFP constants
NSString *const kDFPAdServer = @"DFP";
NSString *const kDFPBannerAdUnitId = @"/19968336/PrebidMobileValidator_Banner_300x250";
NSString *const kDFPInterstitialAdUnitId = @"/19968336/PrebidMobileValidator_Interstitial";

#pragma mark - Prebid Mobile constants
NSString *const kAccountId = @"aecd6ef7-b992-4e99-9bb8-65e2d984e1dd";
NSString *const kAdUnit1ConfigId = @"05cf943f-0f70-44e3-a49e-bb6f1fb4e98b";
NSString *const kAdUnit2ConfigId = @"05cf943f-0f70-44e3-a49e-bb6f1fb4e98b";
NSUInteger const kPBServerHost = PBServerHostAppNexus;
NSUInteger const kPPriceGranularity = PBPriceGranularityMedium;

NSString *const kAdUnit1Id = @"HomeScreen";
NSString *const kAdUnit2Id = @"NavScreen";

@end
