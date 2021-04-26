//
//  PBMOpenMeasurementEventTracker.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMEventTrackerProtocol.h"

@class OMIDOpenxAdSession;
@class OMIDOpenxVASTProperties;

/**
    Implements PBMEventTrackerProtocol according to the OM specification.
*/
NS_ASSUME_NONNULL_BEGIN
@interface PBMOpenMeasurementEventTracker : NSObject <PBMEventTrackerProtocol>

- (instancetype)initWithSession:(OMIDOpenxAdSession *)session;

@end
NS_ASSUME_NONNULL_END
