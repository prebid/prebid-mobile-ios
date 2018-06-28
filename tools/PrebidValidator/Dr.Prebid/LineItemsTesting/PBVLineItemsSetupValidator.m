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
#import "PBVLineItemsSetupValidator.h"
#import "LineItemKeywordsManager.h"
#import "PBVSharedConstants.h"
#import "MPAdView.h"
#import "MPInterstitialAdController.h"
#import "PBViewTool.h"
#import <PrebidMobile/PBAdUnit.h>
#import "LineItemURLProtocol.h"

@interface PBVLineItemsSetupValidator() <MPAdViewDelegate,
                                         MPInterstitialAdControllerDelegate,
                                         GADBannerViewDelegate,
                                         GADInterstitialDelegate>
@property id adObject;
@property NSMutableString *emailContent;
@end

@implementation PBVLineItemsSetupValidator

- (instancetype)init
{
    self = [super init];
    [NSURLProtocol registerClass:[LineItemURLProtocol class]];
    return self;
}

- (void)startTest
{
    NSString *host = [[NSUserDefaults standardUserDefaults]stringForKey:kPBHostKey];
    if ([host isEqualToString:kRubiconString]) {
        [self.delegate lineItemsWereNotSetupProperly];
            _emailContent = [[NSMutableString alloc]init];
        [_emailContent appendString:@"Rubicon line items tests are not supported yet."];
        return;
    }
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *bidPrice = [[NSUserDefaults standardUserDefaults] stringForKey:kBidPriceKey];
    GADAdSize GADAdSize = kGADAdSizeInvalid;
    CGSize adSize = CGSizeZero;
    if ([adSizeString isEqualToString:kBannerSizeString]) {
        GADAdSize = kGADAdSizeBanner;
        adSize = CGSizeMake(kBannerSizeWidth, kBannerSizeHeight);
    } else if ([adSizeString isEqualToString:kMediumRectangleSizeString]) {
        GADAdSize = kGADAdSizeMediumRectangle;
        adSize = CGSizeMake(kMediumRectangleSizeWidth, kMediumRectangleSizeHeight);
    } else if ([adSizeString isEqualToString:kInterstitialSizeString]) {
        adSize = CGSizeMake(kInterstitialSizeWidth, kInterstitialSizeHeight);
    }
    _emailContent = [[NSMutableString alloc]init];
    [_emailContent appendString:@"To replicate the tests that are testing your line items setup, start a project without prebid installed, do the following list of actions: \n"];
    if ([adServerName isEqualToString:kMoPubString]) {
        if ([adFormatName isEqualToString:kBannerString]) {
          
            NSDictionary *keywords = [[LineItemKeywordsManager sharedManager] keywordsWithBidPrice:bidPrice forSize:adSizeString];
            MPAdView *adView = [self createMPAdViewWithAdUnitId:adUnitID WithSize:adSize WithKeywords:keywords];
            self.adObject = adView;
            [adView loadAd];
            [_emailContent appendString:[ NSString stringWithFormat: @"\n\nCreate a MoPub banner ad with adUnitId \"%@\", size \"%@\", set the keywords \"%@\", load to see if you get a prebid ad.", adUnitID, adSizeString, [self formatMoPubKeywordStringFromDictionary:keywords]] ];
            
        } else if ([adFormatName isEqualToString:kInterstitialString]){
          
                NSDictionary *keywords = [[LineItemKeywordsManager sharedManager] keywordsWithBidPrice:bidPrice forSize:adSizeString];
                MPInterstitialAdController *interstitial = [self createMPInterstitialAdControllerWithAdUnitId:adUnitID WithKeywords:keywords];
            self.adObject = interstitial;
                [interstitial loadAd];
                [_emailContent appendString:[ NSString stringWithFormat: @"\n\nCreate a MoPub interstitial ad with adUnitId \"%@\", set the keywords \"%@\", load to see if you get a prebid ad.", adUnitID, [self formatMoPubKeywordStringFromDictionary:keywords]] ];
            
        }
    } else if([adServerName isEqualToString:kDFPString]){
        if ([adFormatName isEqualToString:kBannerString]) {
          
                NSDictionary *keywords = [[LineItemKeywordsManager sharedManager] keywordsWithBidPrice:bidPrice forSize:adSizeString];
                DFPBannerView *adView = [self createDFPBannerViewWithAdUnitId:adUnitID WithSize:GADAdSize];
                // hack to attach to screen
                adView.frame = CGRectMake(-500, -500 , GADAdSize.size.width, GADAdSize.size.height);
                [((UIViewController *) _delegate).view addSubview:adView];
            self.adObject = adView;
                DFPRequest *request = [DFPRequest request];
                request.customTargeting = keywords;
                [adView loadRequest:request];
                 keywords = [[LineItemKeywordsManager sharedManager] keywordsWithBidPrice:bidPrice forSize:adSizeString];
                 [_emailContent appendString:[ NSString stringWithFormat: @"\n\nCreate a DFP banner ad with adUnitId \"%@\", size \"%@\", set the keywords \"%@\", load to see if you get a prebid ad.", adUnitID, adSizeString, keywords ]];
            
        } else if ([adFormatName isEqualToString:kInterstitialString]){
           
                NSDictionary *keywords = [[LineItemKeywordsManager sharedManager] keywordsWithBidPrice:bidPrice forSize:adSizeString];
                DFPInterstitial *interstitial = [self createDFPInterstitialWithAdUnitId:adUnitID];
            self.adObject = interstitial;
                DFPRequest *request = [DFPRequest request];
                request.customTargeting = keywords;
                [interstitial loadRequest:request];
                keywords = [[LineItemKeywordsManager sharedManager] keywordsWithBidPrice:bidPrice forSize:adSizeString];
                [_emailContent appendString:[ NSString stringWithFormat: @"\n\nCreate a DFP interstitial ad with adUnitId \"%@\", set the keywords \"%@\", load to see if you get a prebid ad.", adUnitID, keywords ]];
            
        }
    }
}

#pragma mark DFP
-(DFPInterstitial *) createDFPInterstitialWithAdUnitId:(NSString *)adUnitID
{
    DFPInterstitial *interstitial = [[DFPInterstitial alloc] initWithAdUnitID:adUnitID];
    interstitial.delegate = self;
    return interstitial;
}

- (DFPBannerView *)createDFPBannerViewWithAdUnitId:(NSString *) adUnitID WithSize:(GADAdSize)GADAdSize
{
    DFPBannerView *banner = [[DFPBannerView alloc] initWithAdSize:GADAdSize];
    banner.delegate = self;
    banner.rootViewController = (UIViewController *) self.delegate;
    banner.adUnitID = adUnitID;
    return banner;
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if ([PBViewTool checkDFPAdViewContainsPBMAd:bannerView]) {
  
            [self.delegate lineItemsWereSetupProperly];
        } else{
            [self.delegate lineItemsWereNotSetupProperly];
        }
    
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{

        [self.delegate lineItemsWereNotSetupProperly];
    
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{

            [self.delegate lineItemsWereSetupProperly];
  
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{

        [self.delegate lineItemsWereNotSetupProperly];
    
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

- (MPAdView *) createMPAdViewWithAdUnitId: (NSString *) adUnitID WithSize: (CGSize)adSize WithKeywords:(NSDictionary *)keywordsDict
{
    NSString *keywordsString = [self formatMoPubKeywordStringFromDictionary:keywordsDict];
    MPAdView *adView = [[MPAdView alloc] initWithAdUnitId:adUnitID
                                                     size:adSize];
    adView.delegate = self;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - adSize.width) / 2.0;
    adView.frame = CGRectMake(x, kAdLocationY, adSize.width, adSize.height);
    [adView setKeywords:keywordsString];
    return adView;
}

- (MPInterstitialAdController *) createMPInterstitialAdControllerWithAdUnitId: (NSString *) adUnitID WithKeywords:(NSDictionary *) keywordsDict
{
    NSString *keywords = [self formatMoPubKeywordStringFromDictionary:keywordsDict];
    Class MPInterstitialClass = [MPInterstitialAdController class];   
    SEL initMethodSel = NSSelectorFromString(@"initWithAdUnitId:");
    id interstitial = [MPInterstitialClass alloc];
    if ([interstitial respondsToSelector:initMethodSel]) {
        NSMethodSignature *methSig = [interstitial methodSignatureForSelector:initMethodSel];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methSig];
        [invocation setSelector:initMethodSel];
        [invocation setTarget:interstitial];
        [invocation setArgument:&adUnitID atIndex:2];
        [invocation invoke];
        NSMutableArray *interstitials = [MPInterstitialClass valueForKey:@"sharedInterstitials"];
        [interstitials addObject:interstitial];
        [(MPInterstitialAdController *)interstitial setKeywords:keywords];
        [(MPInterstitialAdController *)interstitial setDelegate:self];
    }
    return interstitial;
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
 
            [self.delegate lineItemsWereSetupProperly];

}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{

        [self.delegate lineItemsWereNotSetupProperly];
    
}

-(void)adViewDidLoadAd:(MPAdView *)view
{
    __weak PBVLineItemsSetupValidator *weakSelf = self;
    
    [PBViewTool checkMPAdViewContainsPBMAd:view
                       withCompletionHandler:^(BOOL result) {
                           __strong PBVLineItemsSetupValidator *strongSelf = weakSelf;
                           if (result) {
                  
                                   [strongSelf.delegate lineItemsWereSetupProperly];
                               } else {
                                   [strongSelf.delegate lineItemsWereNotSetupProperly];
                               }
                           
                       }];
 
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{

        [self.delegate lineItemsWereNotSetupProperly];
    
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return (UIViewController *)self.delegate;
}

- (NSDictionary *) getDisplayable
{
    return self.adObject;
}

- (NSString *)getEmailContent
{
    return [_emailContent copy];
}
@end

