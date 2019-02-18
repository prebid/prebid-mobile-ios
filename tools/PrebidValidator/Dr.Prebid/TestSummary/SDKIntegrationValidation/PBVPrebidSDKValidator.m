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
#import "PBVPrebidSDKValidator.h"
#import "PBVSharedConstants.h"
#import "MPAdView.h"
#import "MPWebView.h"
#import <WebKit/WebKit.h>
#import "MPInterstitialAdController.h"
#import <GoogleMobileAds/DFPBannerView.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import "PBViewTool.h"
#import "SDKValidationURLProtocol.h"

@import PrebidMobile;

@interface PBVPrebidSDKValidator() <CLLocationManagerDelegate,
                                    MPAdViewDelegate,
                                    MPInterstitialAdControllerDelegate,
                                    GADBannerViewDelegate,
                                    GADInterstitialDelegate,
                                    SDKValidationURLProtocolDelegate>
@property (nonatomic, readwrite) CLLocationManager *locationManager;
@property Boolean initialPrebidServerRequestReceived;
@property Boolean initialPrebidServerResponseReceived;
@property Boolean bidReceived;
@property NSString *adServerRequest;
@property NSString *adServerResponse;
@property NSString *adServerRequestPostData;
@property id adObject;
@end

@implementation PBVPrebidSDKValidator

- (instancetype)initWithDelegate: (id<PBVPrebidSDKValidatorDelegate>) delegate
{
    self = [super init];
    if (self) {
        self.initialPrebidServerRequestReceived = NO;
        self.initialPrebidServerResponseReceived = NO;
        self.bidReceived = NO;
        [SDKValidationURLProtocol setDelegate:self];
        [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
        self.delegate = delegate;
        [self enablePrebidLogs];
        [self setupPrebidAndRegisterAdUnits];
    }
    return self;
}

#pragma mark - Prebid Mobile Setup
- (void)enablePrebidLogs {
   // [PBLogManager setPBLogLevel:PBLogLevelAll];
}

- (BOOL)setupPrebidAndRegisterAdUnits {
    @try {
        // Prebid Mobile setup!
        [self setupPrebidLocationManager];
        //[self setPrebidTargetingParams];
        
        // Retriev settings from core data and create ad unit based on that
        NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
        //NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
        NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
        NSString *configId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBConfigKey];
        NSString *accountId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBAccountKey];
        AdUnit *adUnit;
        // todo Wei Zhang to support native and video in the future
        if([adFormatName isEqualToString:kBannerString]) {
            adUnit = [[BannerAdUnit alloc] initWithConfigId:configId size:CGSizeMake(320, 50)];
            // set size on adUnit
            NSMutableArray* array = [NSMutableArray new];
            if ([adSizeString isEqualToString: kSizeString320x50]) {
                [array addObject:[NSValue valueWithCGSize:CGSizeMake(320, 50)]];
                [( (BannerAdUnit *) adUnit) addAdditionalSizeWithSizes:array];
            } else if ([adSizeString isEqualToString: kSizeString300x250]) {
                [array addObject:[NSValue valueWithCGSize:CGSizeMake(300, 250)]];
                [( (BannerAdUnit *) adUnit) addAdditionalSizeWithSizes:array];
            } else if ([adSizeString isEqualToString:kSizeString320x480]){
                [array addObject:[NSValue valueWithCGSize:CGSizeMake(320, 480)]];
                [( (BannerAdUnit *) adUnit) addAdditionalSizeWithSizes:array];
            } else if ([adSizeString isEqualToString:kSizeString320x100]){
                [array addObject:[NSValue valueWithCGSize:CGSizeMake(320, 100)]];
                [( (BannerAdUnit *) adUnit) addAdditionalSizeWithSizes:array];
            } else if ([adSizeString isEqualToString:kSizeString300x600]){
                [array addObject:[NSValue valueWithCGSize:CGSizeMake(300, 600)]];
                [( (BannerAdUnit *) adUnit) addAdditionalSizeWithSizes:array];
            } else {
                [array addObject:[NSValue valueWithCGSize:CGSizeMake(728, 90)]];
                [( (BannerAdUnit *) adUnit) addAdditionalSizeWithSizes:array];
            }
        } else if ([adFormatName isEqualToString:kInterstitialString]){
            adUnit = [[InterstitialAdUnit alloc] initWithConfigId:configId];
        } else {
            NSLog(@"Native and video not supported for now.");
            return NO;
        }
        //NSArray *adUnits = [NSArray arrayWithObjects:adUnit, nil];
        NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
        NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:kPBHostKey];
        Prebid.shared.prebidServerAccountId = accountId;
        if ([adServerName isEqualToString:kMoPubString]) {
                if ([host isEqualToString:kAppNexusString]) {
                    Prebid.shared.prebidServerHost = PrebidHostAppnexus;
                } else if ([host isEqualToString:kRubiconString]) {
                    Prebid.shared.prebidServerHost = PrebidHostRubicon;
                }
        } else if([adServerName isEqualToString:kDFPString]){
                if ([host isEqualToString:kAppNexusString]) {
                    Prebid.shared.prebidServerHost = PrebidHostAppnexus;
                } else if ([host isEqualToString:kRubiconString]) {
                    Prebid.shared.prebidServerHost = PrebidHostRubicon;
                }
        }
        [self.delegate adUnitRegistered];
    } @catch (NSException *ex) {//(PBException *ex) {
        NSLog(@"%@",[ex reason]);
    } @finally {
        return YES;
    }
}

- (void)setupPrebidLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)setPrebidTargetingParams {
    //Targeting.shared.gender = GenderFemale;
    //    [[PBTargetingParams sharedInstance] setAge:25];
    //    [[PBTargetingParams sharedInstance] setGender:PBTargetingParamsGenderFemale];
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
   // [[PBTargetingParams sharedInstance] setLocation:[locations lastObject]];
}

#pragma mark - PBVPrebidSDKValidator APIs
-(void)startTest
{
    // Retrieve Config
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    // sanity check that whether PBM send the initial request or not
    if (self.initialPrebidServerRequestReceived) {
        [self.delegate requestToPrebidServerSent:NO];
        [self.delegate prebidServerResponseReceived:NO];
        [self.delegate bidReceivedAndCached:NO];
    }
    // Create ad unit
    if ([adServerName isEqualToString:kMoPubString]){
        if ([adFormatName isEqualToString:kBannerString]){
            NSArray *widthHeight = [adSizeString componentsSeparatedByString:@"x"];
            double width = [widthHeight[0] doubleValue];
            double height = [widthHeight[1] doubleValue];
            MPAdView *mopubAdView = [[MPAdView alloc] initWithAdUnitId:adUnitID
                                                         size:CGSizeMake(width, height)];
            [mopubAdView stopAutomaticallyRefreshingContents];
            mopubAdView.delegate = self;
            self.adObject = mopubAdView;
            
//            [PrebidMobile setBidKeywordsOnAdObject:mopubAdView
//                                      withAdUnitId:adUnitID
//                                       withTimeout:600
//                                 completionHandler:^{
//                                     [mopubAdView loadAd];
//                                 }];
            
        } else if([adFormatName isEqualToString:kInterstitialString]){
            MPInterstitialAdController *mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:adUnitID];
            mopubInterstitial.delegate = self;
            self.adObject = mopubInterstitial;
            
//            [PrebidMobile setBidKeywordsOnAdObject:mopubInterstitial withAdUnitId:adUnitID withTimeout:600 completionHandler:^{
//                [mopubInterstitial loadAd];
//            }];
        }
            
    } else if ([adServerName isEqualToString:kDFPString]) {
        if ([adFormatName isEqualToString:kBannerString]) {
            NSArray *widthHeight = [adSizeString componentsSeparatedByString:@"x"];
            double width = [widthHeight[0] doubleValue];
            double height = [widthHeight[1] doubleValue];
            DFPBannerView *dfpAdView = [[DFPBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(width, height))];
            dfpAdView.adUnitID = adUnitID;
            dfpAdView.delegate = self;
            dfpAdView.rootViewController = (UIViewController *)_delegate;
            self.adObject = dfpAdView;
            
//            [PrebidMobile setBidKeywordsOnAdObject:dfpAdView withAdUnitId:adUnitID withTimeout:600 completionHandler:^{
//                [dfpAdView loadRequest:[DFPRequest request]];
//            }];
        } else if([adFormatName isEqualToString:kInterstitialString]){
            DFPInterstitial *dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:adUnitID];
            dfpInterstitial.delegate = self;
            self.adObject = dfpInterstitial;
            
//            [PrebidMobile setBidKeywordsOnAdObject:dfpInterstitial withAdUnitId:adUnitID withTimeout:600 completionHandler:^{
//                [dfpInterstitial loadRequest:[DFPRequest request]];
//            }];
        }
    }
}

- (NSObject *)getAdObject
{
    return self.adObject;
}

- (NSString *)getAdServerRequest
{
    return self.adServerRequest;
}

- (NSString *)getAdServerResponse;
{
    return self.adServerResponse;
}

- (NSString *)getAdServerRequestPostData
{
    return self.adServerRequestPostData;
}
#pragma mark - DFP delegate
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self.delegate adServerResponseContainsPBMCreative:NO];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if ([self.adServerResponse containsString:@"pbm.js"]||[self.adServerResponse containsString:@"creative.js"]) {
        [self.delegate adServerResponseContainsPBMCreative:YES];
    } else {
        [self.delegate adServerResponseContainsPBMCreative:NO];
    }
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if ([self.adServerResponse containsString:@"pbm.js"]||[self.adServerResponse containsString:@"creative.js"]) {
        [self.delegate adServerResponseContainsPBMCreative:YES];
    } else {
        [self.delegate adServerResponseContainsPBMCreative:NO];
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self.delegate adServerResponseContainsPBMCreative:NO];
}


#pragma mark - MoPub delegate
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    if ([self.adServerResponse containsString:@"pbm.js"] || [self.adServerResponse containsString:@"creative.js"]) {
        [self.delegate adServerResponseContainsPBMCreative:YES];
    } else {
        [self.delegate adServerResponseContainsPBMCreative:NO];
    }
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    [self.delegate adServerResponseContainsPBMCreative:NO];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return (UIViewController *)self.delegate; // this should work since we don't test click through here.
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    [PBViewTool checkMPAdViewContainsPBMAd:view withCompletionHandler:^(BOOL result) {
        if( result) {
            [self.delegate adServerResponseContainsPBMCreative:YES];
        } else
        {
            [self.delegate adServerResponseContainsPBMCreative:NO];
        }
    }];
}
- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    [self.delegate adServerResponseContainsPBMCreative:NO];
}

#pragma mark - SDKValidationURLProtocolDelegate
- (void)willInterceptPrebidServerRequest
{
    if (!self.initialPrebidServerRequestReceived) {
        self.initialPrebidServerRequestReceived = YES;
        [self.delegate requestToPrebidServerSent:YES];
    }
}

- (void)didReceivePrebidServerResponse:(NSString *)response
{
    if (!self.initialPrebidServerResponseReceived) {
        self.initialPrebidServerResponseReceived = YES;
        [self.delegate prebidServerResponseReceived:YES];
        if (response != nil) {
            NSError *error =nil;
            NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                [self.delegate bidReceivedAndCached:NO];
            } else {
                Boolean containHbCacheId = NO;
                NSDictionary *response = (NSDictionary *)json;
                if ([[response objectForKey:@"seatbid"] isKindOfClass:[NSArray class]]) {
                    NSArray *seatbids = (NSArray *)[response objectForKey:@"seatbid"];
                    for (id seatbid in seatbids) {
                        if ([seatbid isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *seatbidDict = (NSDictionary *)seatbid;
                            if ([[seatbidDict objectForKey:@"bid"] isKindOfClass:[NSArray class]]) {
                                NSArray *bids = (NSArray *)[seatbidDict objectForKey:@"bid"];
                                for (id bid in bids) {
                                    if ([bid isKindOfClass:[NSDictionary class]]) {
                                        NSDictionary *bidDict = (NSDictionary *)bid;
                                        if ([bidDict.allKeys containsObject:@"ext"]) {
                                            NSDictionary *ext = [bidDict objectForKey:@"ext"];
                                            if ([ext.allKeys containsObject:@"prebid"]) {
                                                NSDictionary *prebid = [ext objectForKey:@"prebid"];
                                                if ([prebid.allKeys containsObject:@"targeting"]) {
                                                    NSDictionary *targeting = [prebid objectForKey:@"targeting"];
                                                    for (NSString *key in targeting.allKeys) {
                                                        if ([key isEqualToString:@"hb_cache_id"]) {
                                                            containHbCacheId = YES;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (containHbCacheId) {
                    [self.delegate bidReceivedAndCached:YES];
                } else {
                    [self.delegate bidReceivedAndCached:NO];
                }
            }
        } else {
            [self.delegate bidReceivedAndCached:NO];
        }
    }
}

- (void)willInterceptAdServerRequest:(NSString *)request withPostData:(NSString *)data
{
    self.adServerRequest = request;
    self.adServerRequestPostData = data;
    [self.delegate adServerRequestSent:request andPostData: data];
}

- (void)didReceiveAdServerResponse:(NSString *)response forRequest:(NSString *)request
{
    self.adServerResponse = response;
}
    
@end
