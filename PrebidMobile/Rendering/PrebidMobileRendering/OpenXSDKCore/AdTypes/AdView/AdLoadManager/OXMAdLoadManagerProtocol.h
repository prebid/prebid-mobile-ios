//
//  OXMAdLoadManagerProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXMAdLoadManagerDelegate.h"
#import "OXMTransactionDelegate.h"

@class OXMAdConfiguration;
@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@protocol OXMAdLoadManagerProtocol <NSObject, OXMTransactionDelegate>

@property (nonatomic, weak, nullable) id<OXMAdLoadManagerDelegate> adLoadManagerDelegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
                   adConfiguration:(OXMAdConfiguration *)adConfiguration;

@end
NS_ASSUME_NONNULL_END
