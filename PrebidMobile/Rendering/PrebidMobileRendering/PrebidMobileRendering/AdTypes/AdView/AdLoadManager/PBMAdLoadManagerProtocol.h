//
//  PBMAdLoadManagerProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMAdLoadManagerDelegate.h"
#import "PBMTransactionDelegate.h"

@class PBMAdConfiguration;
@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@protocol PBMAdLoadManagerProtocol <NSObject, PBMTransactionDelegate>

@property (nonatomic, weak, nullable) id<PBMAdLoadManagerDelegate> adLoadManagerDelegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                   adConfiguration:(PBMAdConfiguration *)adConfiguration;

@end
NS_ASSUME_NONNULL_END
