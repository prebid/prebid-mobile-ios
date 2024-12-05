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

#import <Foundation/Foundation.h>

// PBMCreativeModel is visible to the publisher, and defines:
// --- duration indicates the time the creative will display for
// -------- A negative value indicates that this field has not been set
// -------- A value of 0 indicates an indefinite time
// -------- A postitive value indicates that this creative will be displayed for that many seconds
// --- width is the width of the creative, in pixels
// --- height is the height of the creative, in pixels
// --- creativeData is a String:String dictionary that contains all of the data needed to display the creative in a capable view
// -------- Example: An HTML creative would include key "html" with the html code for that creative as the value. A video creative would have a key "videourl" that would point to the asset to be played
// --- trackEvent functions take an enum or string, and cause the tracking URLs associated with those events to be fired
// --- baseURL is an optional base URL to use when loading in an PBMWebView
// @objc and public because it will be used by publishers to display an ad in their own view

@class PBMAdDetails;
@class PBMAdConfiguration;
@class PBMAdModelEventTracker;
@class PBMVideoVerificationParameters;

NS_ASSUME_NONNULL_BEGIN
@interface PBMCreativeModel : NSObject

@property (nonatomic, strong, nullable) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nullable) PBMAdModelEventTracker *eventTracker;
@property (nonatomic, copy, nullable) NSNumber *displayDurationInSeconds;
@property (nonatomic, strong, nullable) NSNumber *skipOffset;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, copy, nullable) NSString *html;
@property (nonatomic, copy, nullable) NSString *targetURL;
@property (nonatomic, copy, nullable) NSString *videoFileURL;
@property (nonatomic, copy, nullable) NSString *revenue;
@property (nonatomic, strong, nullable) PBMVideoVerificationParameters* verificationParameters;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> *trackingURLs;

@property (nonatomic, copy, nullable) NSString *adTrackingTemplateURL;
@property (nonatomic, strong, nullable) PBMAdDetails *adDetails;
@property (nonatomic, copy, nullable) NSString *clickThroughURL;
@property (nonatomic, assign) BOOL isCompanionAd;
@property (atomic, assign) bool hasCompanionAd;

// NOTE: for rewarded ads only
@property (nonatomic, assign) BOOL userHasEarnedReward;
@property (nonatomic, assign) BOOL userPostRewardEventSent;

@property (nonatomic, strong, nullable) NSNumber * rewardTime;
@property (nonatomic, strong, nullable) NSNumber * postRewardTime;

- (instancetype)initWithAdConfiguration:(nonnull PBMAdConfiguration *)adConfiguration;

@end
NS_ASSUME_NONNULL_END
