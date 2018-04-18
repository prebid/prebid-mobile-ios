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

@interface PBVPrebidSDKValidator() <CLLocationManagerDelegate,
                                    MPAdViewDelegate,
                                    MPInterstitialAdControllerDelegate>
@property (nonatomic, readwrite) CLLocationManager *locationManager;
@property MPAdView *mopubAdView;
@property MPInterstitialAdController *mopubInterstitial;
@property void (^testResult)(Boolean);
@end

@implementation PBVPrebidSDKValidator

- (instancetype)init
{
    self = [super init];
    if (self) {
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
        [self setPrebidTargetingParams];
        
        // Retriev settings from core data and create ad unit based on that
        NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
        NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
        NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
        NSString *configId = [[NSUserDefaults standardUserDefaults] stringForKey:kPBConfigKey];
        PBAdUnit *adUnit;
        // todo Wei Zhang to support native and video in the future
        if([adFormatName isEqualToString:kBanner]) {
            adUnit = [[PBBannerAdUnit alloc]initWithAdUnitIdentifier:adUnitID andConfigId:configId];
            // set size on adUnit
            if (adSizeString == kBannerSizeString) {
                [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(320, 50)];
            } else if (adSizeString == kMediumRectangleSizeString) {
                [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(300, 250)];
            } else {
                [( (PBBannerAdUnit *) adUnit) addSize: CGSizeMake(320, 480)];
            }
        } else if ([adFormatName isEqualToString:kInterstitial]){
            adUnit = [[PBInterstitialAdUnit alloc] initWithAdUnitIdentifier:adUnitID andConfigId:configId];
        } else {
            NSLog(@"Native and vide not supported for now.");
            return NO;
        }
        NSArray *adUnits = [NSArray arrayWithObjects:adUnit, nil];
        
        [PrebidMobile registerAdUnits:adUnits withAccountId:kAccountId withHost:PBServerHostAppNexus andPrimaryAdServer:PBPrimaryAdServerMoPub];
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
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    NSDictionary *settings = @{kAdServer : @"MoPub",
                               kPlacementId : adUnitID,
                               kSize : adSizeString};
    UIViewController *vcToShow = [[BannerTestsViewController alloc] initWithSettings:settings];
    return vcToShow;
}
-(void)startTest
{
    NSLog(@"Start creating MoPub ad view..");
    // Retrieve Config
    NSString *adServerName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdServerNameKey];
    NSString *adFormatName = [[NSUserDefaults standardUserDefaults] stringForKey:kAdFormatNameKey];
    NSString *adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kAdUnitIdKey];
    NSString *adSizeString = [[NSUserDefaults standardUserDefaults] stringForKey:kAdSizeKey];
    NSArray *widthHeight = [adSizeString componentsSeparatedByString:@"x"];
    double width = [widthHeight[0] doubleValue];
    double height = [widthHeight[1] doubleValue];
    // Create TestAd ad unit
    if ([adServerName isEqualToString:kMoPubString]){
        if ([adFormatName isEqualToString:kBanner]){
            _mopubAdView = [[MPAdView alloc] initWithAdUnitId:adUnitID
                                                         size:CGSizeMake(width, height)];
            [_mopubAdView stopAutomaticallyRefreshingContents];
            _mopubAdView.delegate = self;
            [PrebidMobile setBidKeywordsOnAdObject:_mopubAdView
                                      withAdUnitId:adUnitID
                                       withTimeout:600
                                 completionHandler:^{
                                     [_mopubAdView loadAd];
                                 }];
        } else if([adFormatName isEqualToString:kInterstitial]){
            _mopubInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:kMoPubInterstitialAdUnitId];
            _mopubInterstitial.delegate = self;
            [PrebidMobile setBidKeywordsOnAdObject:_mopubInterstitial withAdUnitId:adUnitID withTimeout:600 completionHandler:^{
                [_mopubInterstitial loadAd];
            }];
        }
            
    } else {
        
    }
}

#pragma mark - MoPubAdView delegate
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    [interstitial showFromViewController:[self getViewController]];
    //    for(UIView *i in interstitial.view.subviews){
//        if([i isKindOfClass:[MPWebView class]]){
//            MPWebView *wv = (MPWebView *) i;
//            [wv evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//                NSString *content= (NSString *)result;
//                if ([content containsString:@"prebid/pbm.js"]) {
//                    [_delegate testDidPass];
//                    return;
//                }
//            }];
//        }
//    }
//    [_delegate testDidFail];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    [_delegate testDidFail];
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    for(UIView *i in view.subviews){
        if([i isKindOfClass:[MPWebView class]]){
            MPWebView *wv = (MPWebView *) i;
            [wv evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                NSString *content= (NSString *)result;
                if ([content containsString:@"prebid/pbm.js"]) {
                    [_delegate testDidPass];
                    return;
                }
            }];
        }
    }
    [_delegate testDidFail];
}
- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    [_delegate testDidFail];
}


    
@end
