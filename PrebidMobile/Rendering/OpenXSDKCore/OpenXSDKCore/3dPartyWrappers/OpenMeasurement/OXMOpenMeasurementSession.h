//
//  OXMOpenMeasurementSession.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OXMEventTrackerProtocol.h"
#import "OXMOpenMeasurementFriendlyObstructionPurpose.h"

@class OMIDOpenxAdSessionContext;
@class OMIDOpenxAdSessionConfiguration;
@class OXMVideoVerificationParameters;

NS_ASSUME_NONNULL_BEGIN
@interface OXMOpenMeasurementSession : NSObject

@property (nonatomic, readonly) id<OXMEventTrackerProtocol> eventTracker;

- (nonnull)initWithContext:(OMIDOpenxAdSessionContext *)context
             configuration:(OMIDOpenxAdSessionConfiguration *)configuration;

#pragma mark - OXMOpenMeasurementSessionProtocol

- (void)start;

- (void)addFriendlyObstruction:(UIView *)friendlyObstruction purpose:(OXMOpenMeasurementFriendlyObstructionPurpose)purpose;

#pragma mark - Methods

- (void)setupMainView:(UIView *)mainView;


@end
NS_ASSUME_NONNULL_END
