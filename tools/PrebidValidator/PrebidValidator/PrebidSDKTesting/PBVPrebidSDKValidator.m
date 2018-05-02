//
//  PBVPrebidSDKValidator.m
//  PrebidMobileValidator
//
//  Created by Wei Zhang on 4/17/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

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
#import "BannerTestsViewController.h"
#import <WebKit/WebKit.h>
#import "MPInterstitialAdController.h"
#import "InterstitialTestsViewController.h"
#import <GoogleMobileAds/DFPBannerView.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import "PBViewTool.h"

@interface PBVPrebidSDKValidator() <CLLocationManagerDelegate,
                                    MPAdViewDelegate,
                                    MPInterstitialAdControllerDelegate,
                                    GADBannerViewDelegate,
                                    GADInterstitialDelegate>
@property (nonatomic, readwrite) CLLocationManager *locationManager;
@property DFPBannerView *dfpAdView;
@property DFPInterstitial *dfpInterstitial;
@property id adObject;
@end

@implementation PBVPrebidSDKValidator

- (instancetype)init
{
    self = [super init];
    if (self) {
        //        [self enablePrebidLogs]; TODO: add this back
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
        [self setPrebidTargetingParams];
        
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
            if ([adSizeString isEqualToString: kBannerSizeString]) {
                [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(320, 50)];
            } else if ([adSizeString isEqualToString: kMediumRectangleSizeString]) {
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
        if ([adServerName isEqualToString:kMoPubString]) {
            [PrebidMobile registerAdUnits:adUnits withAccountId:accountId withHost:PBServerHostAppNexus andPrimaryAdServer:PBPrimaryAdServerMoPub];
        } else if([adServerName isEqualToString:kDFPString]){
            [PrebidMobile registerAdUnits:adUnits withAccountId:accountId withHost:PBServerHostAppNexus andPrimaryAdServer:PBPrimaryAdServerDFP];
        }
        
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

- (UIViewController *)getViewController
{
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    NSDictionary *settings = @{kAdServerNameKey : adServerName,
                               kAdUnitIdKey : adUnitID,
                               kAdSizeKey : adSizeString};
    UIViewController *vcToShow;
    if ([adFormatName isEqualToString:kBannerString]) {
        vcToShow= [[BannerTestsViewController alloc] initWithSettings:settings];
    } else {
        vcToShow = [[InterstitialTestsViewController alloc] initWithSettings:settings];
    }
    return vcToShow;
}

-(void)startTest
{
    // Retrieve Config
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    NSArray *widthHeight = [adSizeString componentsSeparatedByString:@"x"];
    double width = [widthHeight[0] doubleValue];
    double height = [widthHeight[1] doubleValue];
    // Create ad unit
    if ([adServerName isEqualToString:kMoPubString]){
        if ([adFormatName isEqualToString:kBannerString]){
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
            DFPBannerView *dfpAdView = [[DFPBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(width, height))];
            _adObject = dfpAdView;
            dfpAdView.adUnitID = adUnitID;
            dfpAdView.delegate = self;
            dfpAdView.rootViewController = (UIViewController *)_delegate;
            // hack for dfp to load a webview
            dfpAdView.frame = CGRectMake(-300,-250 ,300,250);
            [((UIViewController *) _delegate).view addSubview:dfpAdView];
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
#pragma mark - DFP delegate
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    [_delegate sdkIntegrationDidFail];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [_delegate sdkIntegrationDidPass]; // Unable to get the ad before acutally showing it, pass for all ad loaded cases
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if ([PBViewTool checkDFPAdViewContainsPBMAd:bannerView]) {
        [_delegate sdkIntegrationDidPass];
    } else {
        [_delegate sdkIntegrationDidFail];
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    [_delegate sdkIntegrationDidFail];
}


#pragma mark - MoPub delegate
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
     [_delegate sdkIntegrationDidPass]; // Unable to get the ad before acutally showing it, pass for all ad loaded cases
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    [_delegate sdkIntegrationDidFail];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [[UIViewController alloc] init]; // this should work since we don't test click through here.
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    [PBViewTool checkMPAdViewContainsPBMAd:view withCompletionHandler:^(BOOL result) {
        if( result) {
            [_delegate sdkIntegrationDidPass];
        } else
        {
            [_delegate sdkIntegrationDidFail];
        }
    }];
}
- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    [_delegate sdkIntegrationDidFail];
}
    
@end
