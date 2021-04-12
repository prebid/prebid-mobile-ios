//
//  OXMAdLoadManagerBase.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXMAdConfiguration.h"
#import "OXMAdLoadManagerDelegate.h"
#import "OXMAdLoadManagerProtocol.h"

@class OXMModalManager;
@class OXMCreativeModel;

@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface OXMAdLoadManagerBase : NSObject <OXMAdLoadManagerProtocol>

@property (nonatomic, weak, nullable) id<OXMAdLoadManagerDelegate> adLoadManagerDelegate;
@property (nonatomic, strong) id<OXMServerConnectionProtocol> connection;
@property (nonatomic, strong) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
                   adConfiguration:(OXMAdConfiguration *)adConfiguration NS_DESIGNATED_INITIALIZER;

- (void)makeCreativesWithCreativeModels:(NSArray<OXMCreativeModel *> *)creativeModels;

- (void)requestCompletedFailure:(NSError *)error;

@end
NS_ASSUME_NONNULL_END
