//
//  PBMCreativeFactoryJob.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMCreativeResolutionDelegate.h"

@class PBMCreativeModel;
@class PBMAbstractCreative;
@class PBMTransaction;
@class PBMCreativeFactoryJob;

@protocol PBMServerConnectionProtocol;

typedef enum PBMCreativeFactoryJobState : NSUInteger {
    PBMCreativeFactoryJobStateInitialized,
    PBMCreativeFactoryJobStateRunning,
    PBMCreativeFactoryJobStateSuccess,
    PBMCreativeFactoryJobStateError
} PBMCreativeFactoryJobState;

typedef void(^PBMCreativeFactoryJobFinishedCallback)(PBMCreativeFactoryJob * _Nonnull, NSError * _Nullable);

@interface PBMCreativeFactoryJob : NSObject <PBMCreativeResolutionDelegate>

@property (nonatomic, strong, nonnull) PBMAbstractCreative *creative;
@property (nonatomic, assign) PBMCreativeFactoryJobState state;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initFromCreativeModel:(nonnull PBMCreativeModel *)creativeModel
                                  transaction:(nonnull PBMTransaction *)transaction
                                  serverConnection:(nonnull id<PBMServerConnectionProtocol>)serverConnection
                              finishedCallback:(nonnull PBMCreativeFactoryJobFinishedCallback)finishedCallback
                              NS_DESIGNATED_INITIALIZER;

- (void)startJob;

@end
