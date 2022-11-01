/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

#import "AppDelegate.h"

@import PrebidMobile;
@import GoogleMobileAds;
@import AppLovinSDK;
@import PrebidMobileGAMEventHandlers;
@import PrebidMobileAdMobAdapters;
@import PrebidMobileMAXAdapters;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Targeting.shared.userGender = GenderMale;
    
    // User Id from External Third Party Sources
    NSMutableArray<ExternalUserId *>  *externalUserIdArray  = [[NSMutableArray<ExternalUserId *> alloc] init];
    [externalUserIdArray addObject:[[ExternalUserId alloc]initWithSource:@"adserver.org" identifier:@"111111111111" atype:nil ext:@{@"rtiPartner" : @"TDID"}]];
    [externalUserIdArray addObject:[[ExternalUserId alloc]initWithSource:@"netid.de" identifier:@"999888777" atype:nil ext:nil]];
    [externalUserIdArray addObject:[[ExternalUserId alloc]initWithSource:@"criteo.com" identifier:@"_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N" atype:nil ext:nil]];
    [externalUserIdArray addObject:[[ExternalUserId alloc]initWithSource:@"liveramp.com" identifier:@"AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg" atype:nil ext:nil]];
    [externalUserIdArray addObject:[[ExternalUserId alloc]initWithSource:@"sharedid.org" identifier:@"111111111111" atype:[NSNumber numberWithInt:1] ext:@{@"third" : @"01ERJWE5FS4RAZKG6SKQ3ZYSKV"}]];
    
    Prebid.shared.externalUserIdArray = externalUserIdArray;
    
    [Prebid initializeSDK:^(enum PrebidInitializationStatus status, NSError * _Nullable error) {}];
    
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ GADSimulatorID ];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {}];
    
    [GAMUtils.shared initializeGAM];

    [AdMobUtils initializeGAD];
    
    [ALSdk shared].mediationProvider = @"max";
    [ALSdk shared].userIdentifier = @"USER_ID";
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
        PBMLogInfo(@"%@", ALSdk.shared.isInitialized ? @"YES" : @"NO");
    }];
    return YES;
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
