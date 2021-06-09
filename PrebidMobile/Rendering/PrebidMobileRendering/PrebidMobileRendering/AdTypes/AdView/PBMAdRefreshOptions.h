/*   Copyright 2018-2021 Prebid.org, Inc.

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

// Return results when restarting refresh timers.
typedef NS_ENUM(NSUInteger, PBMAdRefreshType) {     // For more info see: PBMAdViewManager:getRefreshOptions
    PBMAdRefreshType_StopWithRefreshDelay = 1,      // Do Not Refresh (autoRefreshDelay is nil or negative)
    PBMAdRefreshType_StopWithRefreshMax,            // AutoRefreshMax has been reached
    PBMAdRefreshType_ReloadLater,                   // Reload after given delay
};

@interface PBMAdRefreshOptions : NSObject

@property (nonatomic, assign) PBMAdRefreshType type;
@property (nonatomic, assign) NSInteger delay;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithType:(PBMAdRefreshType)type delay:(NSInteger)delay NS_DESIGNATED_INITIALIZER;

@end

