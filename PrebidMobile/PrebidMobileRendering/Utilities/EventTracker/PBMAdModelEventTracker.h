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
#import "PBMEventTrackerProtocol.h"

@class PBMCreativeModel;
@protocol PrebidServerConnectionProtocol;

/**
 Implements PBMEventTrackerProtocol according to ad model received from the server.
 Tracking for ACJ/VAST implemented via making requests with particular URLs received in the ad model.
*/
NS_ASSUME_NONNULL_BEGIN
@interface PBMAdModelEventTracker : NSObject <PBMEventTrackerProtocol>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                     serverConnection:(id<PrebidServerConnectionProtocol>)serverConnection NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
