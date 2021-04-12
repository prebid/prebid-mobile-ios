//
//  OXMCreativeFactoryJob.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMCreativeResolutionDelegate.h"

@class OXMCreativeModel;
@class OXMAbstractCreative;
@class OXMTransaction;
@class OXMCreativeFactoryJob;

@protocol OXMServerConnectionProtocol;

typedef enum OXMCreativeFactoryJobState : NSUInteger {
    OXMCreativeFactoryJobStateInitialized,
    OXMCreativeFactoryJobStateRunning,
    OXMCreativeFactoryJobStateSuccess,
    OXMCreativeFactoryJobStateError
} OXMCreativeFactoryJobState;

typedef void(^OXMCreativeFactoryJobFinishedCallback)(OXMCreativeFactoryJob * _Nonnull, NSError * _Nullable);

@interface OXMCreativeFactoryJob : NSObject <OXMCreativeResolutionDelegate>

@property (nonatomic, strong, nonnull) OXMAbstractCreative *creative;
@property (nonatomic, assign) OXMCreativeFactoryJobState state;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initFromCreativeModel:(nonnull OXMCreativeModel *)creativeModel
                                  transaction:(nonnull OXMTransaction *)transaction
                                  serverConnection:(nonnull id<OXMServerConnectionProtocol>)serverConnection
                              finishedCallback:(nonnull OXMCreativeFactoryJobFinishedCallback)finishedCallback
                              NS_DESIGNATED_INITIALIZER;

- (void)startJob;

@end
