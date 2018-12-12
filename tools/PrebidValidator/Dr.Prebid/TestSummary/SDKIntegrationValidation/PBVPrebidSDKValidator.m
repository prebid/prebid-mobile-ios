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
#import <PrebidMobile/PBBannerAdUnit.h>
#import <PrebidMobile/PBException.h>
#import <PrebidMobile/PBInterstitialAdUnit.h>
#import <PrebidMobile/PBTargetingParams.h>
#import <PrebidMobile/PrebidMobile.h>
#import <PrebidMobile/PBLogging.h>
#import "PBVSharedConstants.h"
#import "MPAdView.h"
#import "MPWebView.h"
#import <WebKit/WebKit.h>
#import "MPInterstitialAdController.h"
#import <GoogleMobileAds/DFPBannerView.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import "PBViewTool.h"
#import "SDKValidationURLProtocol.h"

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
    [PBLogManager setPBLogLevel:PBLogLevelAll];
}

- (BOOL)setupPrebidAndRegisterAdUnits {
    @try {
        // Prebid Mobile setup!
        [self setupPrebidLocationManager];
        //[self setPrebidTargetingParams];
        
        // Retriev settings from core data and create ad unit based on that
        NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
        NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
        NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
        NSString *configId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBConfigKey];
        NSString *accountId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBAccountKey];
        PBAdUnit *adUnit;
        // todo Wei Zhang to support native and video in the future
        if([adFormatName isEqualToString:kBannerString]) {
            adUnit = [[PBBannerAdUnit alloc]initWithAdUnitIdentifier:adUnitID andConfigId:configId];
            // set size on adUnit
            if ([adSizeString isEqualToString: kSizeString320x50]) {
                [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(320, 50)];
            } else if ([adSizeString isEqualToString: kSizeString300x250]) {
                [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(300, 250)];
            } else {
                [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(320, 480)];
            }
        } else if ([adFormatName isEqualToString:kInterstitialString]){
            adUnit = [[PBInterstitialAdUnit alloc] initWithAdUnitIdentifier:adUnitID andConfigId:configId];
        } else {
            NSLog(@"Native and video not supported for now.");
            return NO;
        }
        NSArray *adUnits = [NSArray arrayWithObjects:adUnit, nil];
        NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
        NSString *host = [[NSUserDefaults standardUserDefaults] stringForKey:kPBHostKey];
        if ([adServerName isEqualToString:kMoPubString]) {
            if ([host isEqualToString:kAppNexusString]) {
                [PrebidMobile registerAdUnits:adUnits withAccountId:accountId withHost:PBServerHostAppNexus andPrimaryAdServer:PBPrimaryAdServerMoPub];
            } else if ([host isEqualToString:kRubiconString]) {
                [PrebidMobile registerAdUnits:adUnits withAccountId:accountId withHost:PBServerHostRubicon andPrimaryAdServer:PBPrimaryAdServerMoPub];
            }
        } else if([adServerName isEqualToString:kDFPString]){
            if ([host isEqualToString:kAppNexusString]) {
                [PrebidMobile registerAdUnits:adUnits withAccountId:accountId withHost:PBServerHostAppNexus andPrimaryAdServer:PBPrimaryAdServerDFP];
            } else if ([host isEqualToString:kRubiconString]) {
                [PrebidMobile registerAdUnits:adUnits withAccountId:accountId withHost:PBServerHostRubicon andPrimaryAdServer:PBPrimaryAdServerDFP];
            }
        }
        [self.delegate adUnitRegistered];
    } @catch (PBException *ex) {
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
    [[PBTargetingParams sharedInstance] setAge:25];
    [[PBTargetingParams sharedInstance] setGender:PBTargetingParamsGenderFemale];
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[PBTargetingParams sharedInstance] setLocation:[locations lastObject]];
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
            _adObject = mopubAdView;
            [mopubAdView stopAutomaticallyRefreshingContents];
            mopubAdView.delegate = self;
            [PrebidMobile setBidKeywordsOnAdObject:mopubAdView
                                      withAdUnitId:adUnitID
                                       withTimeout:600
                                 completionHandler:^{
                                     [mopubAdView loadAd];
                                 }];
        } else if([adFormatName isEqualToString:kInterstitialString]){
            MPInterstitialAdController *mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:adUnitID];
            _adObject = mopubInterstitial;
            mopubInterstitial.delegate = self;
            [PrebidMobile setBidKeywordsOnAdObject:mopubInterstitial withAdUnitId:adUnitID withTimeout:600 completionHandler:^{
                [mopubInterstitial loadAd];
            }];
        }
            
    } else if ([adServerName isEqualToString:kDFPString]) {
        if ([adFormatName isEqualToString:kBannerString]) {
            NSArray *widthHeight = [adSizeString componentsSeparatedByString:@"x"];
            double width = [widthHeight[0] doubleValue];
            double height = [widthHeight[1] doubleValue];
            DFPBannerView *dfpAdView = [[DFPBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(width, height))];
            _adObject = dfpAdView;
            dfpAdView.adUnitID = adUnitID;
            dfpAdView.delegate = self;
            dfpAdView.rootViewController = (UIViewController *)_delegate;
            [PrebidMobile setBidKeywordsOnAdObject:dfpAdView withAdUnitId:adUnitID withTimeout:600 completionHandler:^{
                [dfpAdView loadRequest:[DFPRequest request]];
            }];
        } else if([adFormatName isEqualToString:kInterstitialString]){
            DFPInterstitial *dfpInterstitial = [[DFPInterstitial alloc] initWithAdUnitID:adUnitID];
            _adObject = dfpInterstitial;
            dfpInterstitial.delegate = self;
            [PrebidMobile setBidKeywordsOnAdObject:dfpInterstitial withAdUnitId:adUnitID withTimeout:600 completionHandler:^{
                [dfpInterstitial loadRequest:[DFPRequest request]];
            }];
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
    return [[UIViewController alloc] init]; // this should work since we don't test click through here.
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
