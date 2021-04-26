//
//  PBMEventManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

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
