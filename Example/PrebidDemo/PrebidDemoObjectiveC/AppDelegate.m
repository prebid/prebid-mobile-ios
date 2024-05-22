/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize Prebid SDK
    [Prebid initializeSDKWithGadMobileAdsVersion:GADGetStringFromVersionNumber(GADMobileAds.sharedInstance.versionNumber) :nil];
    
    Prebid.shared.prebidServerAccountId = @"0689a263-318d-448b-a3d4-b02e8a709d9d";
    [Prebid.shared setCustomPrebidServerWithUrl:@"https://prebid-server-test-j.prebid.org/openrtb2/auction" error:nil];
    // Set sourceapp
    Targeting.shared.sourceapp = @"PrebidDemoObjectiveC";
    
    // Initialize GoogleMobileAds SDK
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ GADSimulatorID ];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {}];
    
    [GAMUtils.shared initializeGAM];
    [AdMobUtils initializeGAD];
    
    // Initialize AppLovin MAX SDK
    [ALSdk shared].mediationProvider = ALMediationProviderMAX;
    [ALSdk shared].userIdentifier = @"USER_ID";
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {}];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}


@end
