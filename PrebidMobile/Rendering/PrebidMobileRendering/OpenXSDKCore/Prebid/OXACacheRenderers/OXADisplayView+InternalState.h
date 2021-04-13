//
//  OXADisplayView+InternalState.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef OXADisplayView_InternalState_h
#define OXADisplayView_InternalState_h

#import "OXADisplayView.h"

@class OXAAdUnitConfig;

@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface OXADisplayView ()

@property (nonatomic, strong, readonly, nullable) id<OXMServerConnectionProtocol> connection;

- (instancetype)initWithFrame:(CGRect)frame bid:(OXABid *)bid adConfiguration:(OXAAdUnitConfig *)adConfiguration;

@end

NS_ASSUME_NONNULL_END

#endif /* OXADisplayView_InternalState_h */
