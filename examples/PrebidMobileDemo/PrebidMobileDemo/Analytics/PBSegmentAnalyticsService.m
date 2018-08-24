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

#import "PBSegmentAnalyticsService.h"
#import <PrebidMobile/PBAnalyticsEvent.h>
#import <Analytics/SEGAnalytics.h>

@implementation PBSegmentAnalyticsService

- (void)initializeWithApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"insert_key_here"];
    configuration.trackApplicationLifecycleEvents = NO; // Enable this to record certain application events automatically!
    configuration.recordScreenViews = NO; // Enable this to record screen views automatically!
    [SEGAnalytics setupWithConfiguration:configuration];
}

- (void)trackEvent:(PBAnalyticsEvent *)event {
    if ([self isSupportedWithEvent:event]) {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        NSDictionary *options = @{ @"context" : @{ @"app" : @{ @"name" : appName }}};
        [[SEGAnalytics sharedAnalytics] track:event.title
                                   properties:event.info
                                      options:options];
    }
}

- (BOOL)isSupportedWithEvent:(PBAnalyticsEvent *)event {
    // check to see if this event is supported, all by default
    return YES;
}

@end
