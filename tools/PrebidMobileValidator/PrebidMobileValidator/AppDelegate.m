//
//  AppDelegate.m
//  PrebidTestApp
//
//  Created by Punnaghai Puviarasu on 4/3/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "AppDelegate.h"

#import <PrebidMobile/PBBannerAdUnit.h>
#import <PrebidMobile/PBException.h>
#import <PrebidMobile/PBInterstitialAdUnit.h>
#import <PrebidMobile/PBTargetingParams.h>
#import <PrebidMobile/PrebidMobile.h>
#import <PrebidMobile/PBLogging.h>
#import "PrebidConstants.h"

@interface AppDelegate ()

@property (nonatomic, readwrite) CLLocationManager *locationManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self enablePrebidLogs];
    [self setupPrebidAndRegisterAdUnits];
    // Override point for customization after application launch.
    return YES;
}

- (void)enablePrebidLogs {
    [PBLogManager setPBLogLevel:PBLogLevelAll];
}

- (BOOL)setupPrebidAndRegisterAdUnits {
    @try {
        // Prebid Mobile setup!
        [self setupPrebidLocationManager];
        
        PBBannerAdUnit *__nullable adUnit1 = [[PBBannerAdUnit alloc] initWithAdUnitIdentifier:kAdUnit1Id andConfigId:kAdUnit1ConfigId];
        PBInterstitialAdUnit *__nullable adUnit2 = [[PBInterstitialAdUnit alloc] initWithAdUnitIdentifier:kAdUnit2Id andConfigId:kAdUnit2ConfigId];
        [adUnit1 addSize:CGSizeMake(300, 250)];
        
        [self setPrebidTargetingParams];
        
        [PrebidMobile registerAdUnits:@[adUnit1, adUnit2] withAccountId:kAccountId withHost:kPBServerHost andPrimaryAdServer:PBPrimaryAdServerDFP];
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
    //[[PBTargetingParams sharedInstance] setCustomTargeting:@"country" withValues:@[@"india", @"malaysia"]];
    //[[PBTargetingParams sharedInstance] setCustomTargeting:@"race" withValues:@[@"asian", @"hispanic", @"asian"]];
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [[PBTargetingParams sharedInstance] setLocation:[locations lastObject]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
