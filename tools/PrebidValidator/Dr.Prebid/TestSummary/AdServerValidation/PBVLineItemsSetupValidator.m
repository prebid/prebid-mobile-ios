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

@import PrebidMobile;
@import GoogleMobileAds;

#import <Foundation/Foundation.h>
#import "PBVLineItemsSetupValidator.h"
#import "LineItemKeywordsManager.h"
#import "PBVSharedConstants.h"
#import "AdServerValidationURLProtocol.h"
#import "NSURLSessionConfiguration+PBProtocols.h"


@interface PBVLineItemsSetupValidator() <   GADBannerViewDelegate,
                                            AdServerValidationURLProtocolDelegate>
@property id adObject;
@property NSString *requestUUID;
@property NSString *adServerResponseString;
@property NSString *adServerRequestString;
@property NSString *adServerRequestPostData;
@property NSDictionary *keywords;
@end

@implementation PBVLineItemsSetupValidator

- (instancetype)init
{
    self = [super init];
    [NSURLProtocol registerClass:[AdServerValidationURLProtocol class]];
    [AdServerValidationURLProtocol setDelegate:self];
    return self;
}

- (void)willInterceptRequest:(NSString *)requestString andPostData:(NSString *) data
{
    if ([requestString containsString:self.requestUUID] || [data containsString:self.requestUUID]) {
        self.adServerRequestString = requestString;
        self.adServerRequestPostData = data;
        BOOL containsKeyValues = YES;
        if ([requestString containsString:@"pubads.g.doubleclick.net/gampad/ads?"]) {
            for (NSString *key in self.keywords.allKeys) {
                NSString *keyValuePair = [NSString stringWithFormat:@"%@%@%@", key,@"%3D", [self.keywords objectForKey:key]];
                if (![requestString containsString:keyValuePair]) {
                    containsKeyValues = NO;
                }
            }
        } else {
            for (NSString *key in self.keywords.allKeys) {
                NSString *keyValuePair = [NSString stringWithFormat:@"%@:%@", key,[self.keywords objectForKey:key]];
                if (![data containsString:keyValuePair]) {
                    containsKeyValues = NO;
                }
            }
        }
        if (containsKeyValues) {
            [self.delegate didFindPrebidKeywordsOnTheAdServerRequest];
        } else {
            [self.delegate didNotFindPrebidKeywordsOnTheAdServerRequest];
        }
    }
}

- (void)didReceiveResponse:(NSString *)responseString forRequest:(NSString *)requestString
{
    if (self.requestUUID != nil && ([requestString containsString:self.requestUUID] || [self.adServerRequestPostData containsString:self.requestUUID])) {
        self.adServerResponseString = responseString;
    }
}

- (void)startTest
{
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *bidPrice = [[NSUserDefaults standardUserDefaults] stringForKey:kBidPriceKey];
        
    GADAdSize GADAdSize = GADAdSizeInvalid;
    CGSize adSize = CGSizeZero;
    if ([adSizeString isEqualToString:kSizeString320x50]) {
        GADAdSize = GADAdSizeBanner;
        adSize = CGSizeMake(320, 50);
    } else if ([adSizeString isEqualToString:kSizeString300x250]) {
        GADAdSize = GADAdSizeMediumRectangle;
        adSize = CGSizeMake(300, 250);
    } else if ([adSizeString isEqualToString:kSizeString320x480]) {
        adSize = CGSizeMake(320, 480);
        GADAdSize = GADAdSizeFromCGSize(adSize);
    } else if ([adSizeString isEqualToString:kSizeString300x600]) {
        adSize = CGSizeMake(300, 600);
        GADAdSize = GADAdSizeFromCGSize(adSize);
    } else if ([adSizeString isEqualToString:kSizeString320x100]) {
        adSize = CGSizeMake(320, 100);
        GADAdSize = GADAdSizeLargeBanner;
    } else if ([adSizeString isEqualToString:kSizeString1x1]) {
        adSize = CGSizeMake(1, 1);
        GADAdSize = GADAdSizeFluid;
    }
     if([adServerName isEqualToString:kDFPString]){
        if ([adFormatName isEqualToString:kBannerString] || [adFormatName isEqualToString:kNativeString]) {
            GAMBannerView *adView = [self createDFPBannerViewWithAdUnitId:adUnitID WithSize:GADAdSize];
            // hack to attach to screen
            adView.frame = CGRectMake(-500, -500 , GADAdSize.size.width, GADAdSize.size.height);
            [((UIViewController *) _delegate).view addSubview:adView];
            self.adObject = adView;
            GAMRequest *request = [GAMRequest request];
            self.keywords = [self createUniqueKeywordsWithBidPrice:bidPrice forSize:adSizeString];
            request.customTargeting = self.keywords;
            [adView loadRequest:request];
        } else if ([adFormatName isEqualToString:kInterstitialString]){
            self.keywords = [self createUniqueKeywordsWithBidPrice:bidPrice forSize:adSizeString];
            GAMRequest *request = [GAMRequest request];
            request.customTargeting = self.keywords;

            [GAMInterstitialAd loadWithAdManagerAdUnitID:adUnitID
                                                 request:request
                                       completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
                if (error) {
                    [self.delegate adServerDidNotRespondWithPrebidCreative:error];
                    return;
                }
                
                if (self.adServerResponseString != nil && ([self.adServerResponseString containsString:@"pbm.js"] || [self.adServerResponseString containsString:@"creative.js"])) {
                    [self.delegate adServerRespondedWithPrebidCreative];
                } else {
                    [self.delegate adServerDidNotRespondWithPrebidCreative:nil];
                }
                
                self.adObject = interstitialAd;
                
            }];

        }
    }
}
- (NSDictionary *) createUniqueKeywordsWithBidPrice:(NSString *)bidPrice forSize:(NSString *)adSizeString
{
    NSString *host = [[NSUserDefaults standardUserDefaults]stringForKey:kPBHostKey];
    NSMutableDictionary *keywords = [[[LineItemKeywordsManager sharedManager] keywordsWithBidPrice:bidPrice forSize:adSizeString forHost:host] mutableCopy];
    self.requestUUID = [[NSUUID UUID] UUIDString];
    [keywords setObject:self.requestUUID forKey:@"hb_dr_prebid"];
    return [keywords copy];
}

#pragma mark DFP
- (GAMBannerView *)createDFPBannerViewWithAdUnitId:(NSString *) adUnitID WithSize:(GADAdSize)GADAdSize
{
    GAMBannerView *banner = [[GAMBannerView alloc] initWithAdSize:GADAdSize];
    banner.delegate = self;
    banner.rootViewController = (UIViewController *) self.delegate;
    banner.adUnitID = adUnitID;
    banner.autoloadEnabled = NO;
    return banner;
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
    if (self.adServerResponseString != nil && ([self.adServerResponseString containsString:@"pbm.js"] || [self.adServerResponseString containsString:@"creative.js"])) {
        [self.delegate adServerRespondedWithPrebidCreative];
    } else {
        [self.delegate adServerDidNotRespondWithPrebidCreative:nil];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    [self.delegate adServerDidNotRespondWithPrebidCreative:error];
}

#pragma mark MoPub
- (NSString *) formatMoPubKeywordStringFromDictionary:(NSDictionary *) keywordsDict
{
    NSString *keywordsString = @"";
    for (NSString *key in keywordsDict) {
        NSString *formatKey = [key stringByAppendingString:@":"];
        NSString *formatKeyword = [formatKey stringByAppendingString:keywordsDict[key]];
        keywordsString = [keywordsString stringByAppendingString:[formatKeyword stringByAppendingString:@","]];
    }
    return keywordsString;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return (UIViewController *)self.delegate;
}

- (NSObject *) getDisplayable
{
    return self.adObject;
}

- (NSString *)getAdServerResponse
{
    return self.adServerResponseString;
}

- (NSString *)getAdServerRequest
{
    return self.adServerRequestString;
}

- (NSString *)getAdServerPostData
{
    return self.adServerRequestPostData;
}
@end

