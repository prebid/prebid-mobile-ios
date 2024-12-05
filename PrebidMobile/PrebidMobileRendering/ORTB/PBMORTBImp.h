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

@class PBMORTBBanner;
@class PBMORTBImpExtPrebid;
@class PBMORTBImpExtSkadn;
@class PBMORTBNative;
@class PBMORTBPmp;
@class PBMORTBVideo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.4: Imp

//This object describes an ad placement or impression being auctioned. A single bid request can include
//multiple Imp objects, a use case for which might be an exchange that supports selling all ad positions on
//a given page. Each Imp object has a required ID so that bids can reference them individually.
//The presence of Banner (Section 3.2.6), Video (Section 3.2.7), and/or Native (Section 3.2.9) objects
//subordinate to the Imp object indicates the type of impression being offered. The publisher can choose
//one such type which is the typical case or mix them at their discretion. However, any given bid for the
//    impression must conform to one of the offered types.
@interface PBMORTBImp : PBMORTBAbstract
    
//A unique identifier for this impression within the context of the bid request (typically, starts with 1 and increments.
@property (nonatomic, copy, nullable) NSString *impID;

//An array of Metric object (Section 3.2.5).
//Note: metric is not supported.

//A Banner object (Section 3.2.6); required if this impression is offered as a banner ad opportunity.
@property (nonatomic, strong, nullable) PBMORTBBanner * banner;

//A Video object (Section 3.2.7); required if this impression is offered as a video ad opportunity.
@property (nonatomic, strong, nullable) PBMORTBVideo *video;

//Note: audio object not supported
//An Audio object (Section 3.2.8); required if this impression is offered as an audio ad opportunity.

//A Native object (Section 3.2.9); required if this impression is offered as a native ad opportunity.
@property (nonatomic, strong, nullable) PBMORTBNative * native;

//A Pmp object (Section 3.2.11) containing any private marketplace deals in effect for this impression.
@property (nonatomic, strong) PBMORTBPmp * pmp;

//Name of ad mediation partner, SDK technology, or player
//responsible for rendering ad (typically video or mobile). Used
//by some ad servers to customize ad code by partner.
//Recommended for video and/or apps.
@property (nonatomic, copy, nullable) NSString *displaymanager;

//Version of ad mediation partner, SDK technology, or player
//responsible for rendering ad (typically video or mobile). Used
//by some ad servers to customize ad code by partner.
//Recommended for video and/or apps.
@property (nonatomic, copy, nullable) NSString *displaymanagerver;

//1 = the ad is interstitial or full screen, 0 = not interstitial
@property (nonatomic, strong) NSNumber *instl;

//Identifier for specific ad placement or ad tag that was used to
//initiate the auction. This can be useful for debugging of any
//issues, or for optimization by the buyer.
@property (nonatomic, copy, nullable) NSString *tagid;

//Minimum bid for this impression expressed in CPM.
//Note: bidfloor is not supported.

//Currency specified using ISO-4217 alpha codes. This may be
//different from bid currency returned by bidder if this is
//allowed by the exchange.
//Note: bidfloorcur is not supported.

//Indicates the type of browser opened upon clicking the
//creative in an app, where 0 = embedded, 1 = native. Note that
//the Safari View Controller in iOS 9.x devices is considered a
//native browser for purposes of this attribute.
//TODO: clarify with Product if this should be informed by PBMSDKConfiguration.useExternalClickthroughBrowser
@property (nonatomic, strong) NSNumber *clickbrowser;

//Flag to indicate if the impression requires secure HTTPS URL
//creative assets and markup, where 0 = non-secure, 1 = secure.
//If omitted, the secure state is unknown, but non-secure HTTP
//support can be assumed.
@property (nonatomic, strong) NSNumber *secure;

//Indicates whether the ad is rewarded
@property (nonatomic, strong, nullable) NSNumber *rewarded;

//Array of exchange-specific names of supported iframe busters.
//Note: iframebuster is not supported.

//Advisory as to the number of seconds that may elapse
//between the auction and the actual impression.
//Note: exp is not supported.

//Note: ext is not supported.
//Placeholder for exchange-specific extensions to OpenRTB.

@property (nonatomic, strong) PBMORTBImpExtPrebid *extPrebid;
@property (nonatomic, strong) PBMORTBImpExtSkadn  *extSkadn;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, id> *extData;
@property (nonatomic, strong, nullable) NSString *extKeywords;
@property (nonatomic, strong, nullable) NSString *extGPID;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
