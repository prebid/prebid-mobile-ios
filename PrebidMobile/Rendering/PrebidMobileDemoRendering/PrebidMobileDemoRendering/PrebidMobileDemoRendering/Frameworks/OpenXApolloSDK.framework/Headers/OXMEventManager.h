//
//  OXMEventManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMEventTrackerProtocol.h"

@class OXMCreativeModel;

/**
    This class is a proxy container for event trackers.
    You can add (and remove) any quantity of trackers.
    Each tracker must correspond to OXMEventTrackerProtocol the OXMEventTracker Protocol.
 
    OXMEventManager implements OXMEventTrackerProtocol.
    It broadcasts protocol calls to the all registered trackers.
 */
NS_ASSUME_NONNULL_BEGIN
@interface OXMEventManager : NSObject <OXMEventTrackerProtocol>

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)registerTracker:(id<OXMEventTrackerProtocol>)tracker;
- (void)unregisterTracker:(id<OXMEventTrackerProtocol>)tracker;

@end
NS_ASSUME_NONNULL_END
