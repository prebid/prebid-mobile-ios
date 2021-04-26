//
//  PBMOpenMeasurementSession.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PBMEventTrackerProtocol.h"
#import "PBMOpenMeasurementFriendlyObstructionPurpose.h"

@class OMIDOpenxAdSessionContext;
@class OMIDOpenxAdSessionConfiguration;
@class PBMVideoVerificationParameters;

NS_ASSUME_NONNULL_BEGIN
@interface PBMOpenMeasurementSession : NSObject

@property (nonatomic, readonly) id<PBMEventTrackerProtocol> eventTracker;

- (nonnull)initWithContext:(OMIDOpenxAdSessionContext *)context
             configuration:(OMIDOpenxAdSessionConfiguration *)configuration;

#pragma mark - PBMOpenMeasurementSessionProtocol

- (void)start;

- (void)addFriendlyObstruction:(UIView *)friendlyObstruction purpose:(PBMOpenMeasurementFriendlyObstructionPurpose)purpose;

#pragma mark - Methods

- (void)setupMainView:(UIView *)mainView;


@end
NS_ASSUME_NONNULL_END
