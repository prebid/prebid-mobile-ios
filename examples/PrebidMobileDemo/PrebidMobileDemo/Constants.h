/*   Copyright 2017 APPNEXUS INC
 
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

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString *const kAdServer;
extern NSString *const kAdType;
extern NSString *const kPlacementId;
extern NSString *const kSize;

extern NSString *const kDefaultPlacementId;
extern NSString *const kDefaultSize;

extern NSString *const kBanner;
extern NSString *const kInterstitial;
extern NSString *const kNative;
extern NSString *const kVideo;

#pragma mark - MoPub constants
extern NSString *const kMoPubAdServer;
extern NSString *const kMoPubBannerAdUnitId;
extern NSString *const kMoPubInterstitialAdUnitId;

#pragma mark - DFP constants
extern NSString *const kDFPAdServer;
extern NSString *const kDFPBannerAdUnitId;
extern NSString *const kDFPInterstitialAdUnitId;

#pragma mark - Prebid Mobile constants
extern NSString *const kAccountId;
extern NSString *const kAdUnit1ConfigId;
extern NSString *const kAdUnit2ConfigId;

extern NSString *const kAdUnit1Id;
extern NSString *const kAdUnit2Id;

extern NSString *const kFBBannerAdUnit;
extern NSString *const kFBIntAdUnit;
extern NSString *const kFBBannerAdUnitConfigId;

@end
