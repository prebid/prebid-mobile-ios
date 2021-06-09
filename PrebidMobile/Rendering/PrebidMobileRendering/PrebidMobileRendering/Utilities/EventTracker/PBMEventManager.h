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

/**
    This class is a proxy container for event trackers.
    You can add (and remove) any quantity of trackers.
    Each tracker must correspond to PBMEventTrackerProtocol the PBMEventTracker Protocol.
 
    PBMEventManager implements PBMEventTrackerProtocol.
    It broadcasts protocol calls to the all registered trackers.
 */
NS_ASSUME_NONNULL_BEGIN
@interface PBMEventManager : NSObject <PBMEventTrackerProtocol>

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)registerTracker:(id<PBMEventTrackerProtocol>)tracker;
- (void)unregisterTracker:(id<PBMEventTrackerProtocol>)tracker;

@end
NS_ASSUME_NONNULL_END
