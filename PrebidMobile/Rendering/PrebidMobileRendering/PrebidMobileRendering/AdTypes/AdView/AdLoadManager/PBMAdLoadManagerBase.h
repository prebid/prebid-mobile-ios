//
//  PBMAdLoadManagerBase.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMAdConfiguration.h"
#import "PBMAdLoadManagerDelegate.h"
#import "PBMAdLoadManagerProtocol.h"

@class PBMModalManager;
@class PBMCreativeModel;

@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMAdLoadManagerBase : NSObject <PBMAdLoadManagerProtocol>

@property (nonatomic, weak, nullable) id<PBMAdLoadManagerDelegate> adLoadManagerDelegate;
@property (nonatomic, strong) id<PBMServerConnectionProtocol> connection;
@property (nonatomic, strong) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                   adConfiguration:(PBMAdConfiguration *)adConfiguration NS_DESIGNATED_INITIALIZER;

- (void)makeCreativesWithCreativeModels:(NSArray<PBMCreativeModel *> *)creativeModels;

- (void)requestCompletedFailure:(NSError *)error;

@end
NS_ASSUME_NONNULL_END
