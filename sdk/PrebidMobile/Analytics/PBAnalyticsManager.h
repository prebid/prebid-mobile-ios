/*   Copyright 2017 Prebid.org, Inc.
 
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PBAnalyticsEvent.h"

@protocol PBAnalyticsService;

@interface PBAnalyticsManager : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

+ (instancetype)sharedInstance;
- (void)initializeWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions;
- (void)trackEvent:(PBAnalyticsEvent *)event;
- (void)trackEventType:(PBAnalyticsEventType)type info:(NSDictionary *)info;
- (void)addService:(id<PBAnalyticsService>)service;
- (void)removeService:(id<PBAnalyticsService>)service;
- (void)removeAllServices;

@end
