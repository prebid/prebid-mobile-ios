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
extern NSString *__nonnull const kPBCustomHostText;
extern NSString *__nonnull const kPBAccountIDText;
extern NSString *__nonnull const kPBConfigIDText;
extern NSString *__nonnull const kPBHostText;

extern NSString *__nonnull const kAdServerNameKey;
extern NSString *__nonnull const kAdFormatNameKey;
extern NSString *__nonnull const kAdSizeKey;
extern NSString *__nonnull const kPBCustomHostKey;
extern NSString *__nonnull const kAdUnitIdKey;
extern NSString *__nonnull const kBidPriceKey;
extern NSString *__nonnull const kPBAccountKey;
extern NSString *__nonnull const kPBConfigKey;
extern NSString *__nonnull const kPBHostKey;
extern NSString *__nonnull const kNativeRequestKey;

extern NSString *__nonnull const kDFPString;

extern NSString *__nonnull const kAdServerResponseCreative;

extern NSString *__nonnull const kBannerString;
extern NSString *__nonnull const kInterstitialString;
extern NSString *__nonnull const kNativeString;
extern NSString *__nonnull const kVideoString;

extern NSString *__nonnull const kSizeString320x50;
extern NSString *__nonnull const kSizeString300x250;
extern NSString *__nonnull const kSizeString320x480;
extern NSString *__nonnull const kSizeString320x100;
extern NSString *__nonnull const kSizeString300x600;
extern NSString *__nonnull const kSizeString728x90;
extern NSString *__nonnull const kSizeString1x1;

static CGFloat const kAdLocationY = 30.0f;
static CGFloat const kAdLabelLocationX = 10.0f;
static CGFloat const kAdLabelLocationY = 5.0f;
static CGFloat const kAdTitleLabelHeight = 20.0f;
static CGFloat const kAdFailedLabelHeight = 50.0f;
static CGFloat const kAdMargin = 10.0f;
static NSString * _Nonnull const kAppNexusString = @"Xandr";
static NSString * _Nonnull const kRubiconString = @"Rubicon";
static NSString * _Nonnull const kCustomString = @"Custom";
static NSString * _Nonnull const kAppNexusPrebidServerEndpoint = @"https://ib.adnxs.com/openrtb2/prebid";
static NSString * _Nonnull const kRubiconPrebidServerEndpoint = @"https://prebid-server.rubiconproject.com/openrtb2/auction";
static NSString * _Nonnull const kCustomPrebidServerEndpoint = @"CustomHostPath";

// Titles for helper pages
static NSString * _Nonnull const kAboutString = @"About";
static NSString * _Nonnull const kGeneralInfoHelpString = @"General Info";
static NSString * _Nonnull const kAdServerInfoHelpString = @"AdServer Info";
static NSString * _Nonnull const kPrebidServerInfoHelpString = @"Prebid Server Info";

static NSString *__nonnull const kAdServerTestHeader = @"Ad Server Setup Validation";
static NSString *__nonnull const kAdServerRequestSentWithKV = @"Ad server request sent and \nKey-Value Targeting sent";
static NSString *__nonnull const kpbmjsreceived = @"Prebid Mobile creative served";

static NSString *__nonnull const kRealTimeHeader = @"Real-Time Demand Validation";
static NSString *__nonnull const kBidRequestSent = @"100 bid requests sent";
static NSString *__nonnull const kBidResponseReceived = @"no bid response received yet";
static NSString *__nonnull const kCPMReceived = @"CPM response time";

static NSString *__nonnull const kSDKHeader = @"End-to-End SDK Validation";
static NSString *__nonnull const kAdUnitRegistered = @"Ad unit registered";
static NSString *__nonnull const kRequestToPrebidServerSent = @"Request to Prebid Server Sent";
static NSString *__nonnull const kPrebidServerResponseReceived = @"Prebid Server response received";
static NSString *__nonnull const kCreativeCached = @"Creative content cached";

static NSString *__nonnull const kFirstLaunch = @"DR.Prebid_first_launch";



