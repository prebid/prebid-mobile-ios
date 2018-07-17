/*
 *    Copyright 2018 Prebid.org, Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




extern NSString *__nonnull const kAdServerLabelText;
extern NSString *__nonnull const kAdFormatLabelText;
extern NSString *__nonnull const kAdSizeLabelText;
extern NSString *__nonnull const kAdUnitIdText;
extern NSString *__nonnull const kBidPriceText;
extern NSString *__nonnull const kPBAccountIDText;
extern NSString *__nonnull const kPBConfigIDText;
extern NSString *__nonnull const KPBHostText;

extern NSString *__nonnull const kAdServerNameKey;
extern NSString *__nonnull const kAdFormatNameKey;
extern NSString *__nonnull const kAdSizeKey;
extern NSString *__nonnull const kAdUnitIdKey;
extern NSString *__nonnull const kBidPriceKey;
extern NSString *__nonnull const kPBAccountKey;
extern NSString *__nonnull const kPBConfigKey;
extern NSString *__nonnull const kPBHostKey;

extern NSString *__nonnull const kMoPubString;
extern NSString *__nonnull const kDFPString;

extern NSString *__nonnull const kBannerString;
extern NSString *__nonnull const kInterstitialString;
extern NSString *__nonnull const kNativeString;
extern NSString *__nonnull const kVideoString;

extern NSString *__nonnull const kBannerSizeString;
extern NSString *__nonnull const kMediumRectangleSizeString;
extern NSString *__nonnull const kInterstitialSizeString;

static CGFloat const kBannerSizeWidth = 320.0f;
static CGFloat const kBannerSizeHeight = 50.0f;
static CGFloat const kMediumRectangleSizeWidth = 300.0f;
static CGFloat const kMediumRectangleSizeHeight = 250.0f;
static CGFloat const kInterstitialSizeWidth = 320.0f;
static CGFloat const kInterstitialSizeHeight = 480.0f;

static CGFloat const kAdLocationY = 30.0f;
static CGFloat const kAdLabelLocationX = 10.0f;
static CGFloat const kAdLabelLocationY = 5.0f;
static CGFloat const kAdTitleLabelHeight = 20.0f;
static CGFloat const kAdFailedLabelHeight = 50.0f;
static CGFloat const kAdMargin = 10.0f;
static NSString * _Nonnull const kAppNexusString = @"AppNexus";
static NSString * _Nonnull const kRubiconString = @"Rubicon";
static NSString * _Nonnull const kAppNexusPrebidServerEndpoint = @"https://prebid.adnxs.com/pbs/v1/openrtb2/auction";
static NSString * _Nonnull const kRubiconPrebidServerEndpoint = @"https://prebid-server.rubiconproject.com/openrtb2/auction";



