//
//  OXMOpenMeasurementEventTracker.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMEventTrackerProtocol.h"

@class OMIDOpenxAdSession;
@class OMIDOpenxVASTProperties;

/**
    Implements OXMEventTrackerProtocol according to the OM specification.
*/
NS_ASSUME_NONNULL_BEGIN
@interface OXMOpenMeasurementEventTracker : NSObject <OXMEventTrackerProtocol>

- (instancetype)initWithSession:(OMIDOpenxAdSession *)session;

@end
NS_ASSUME_NONNULL_END
