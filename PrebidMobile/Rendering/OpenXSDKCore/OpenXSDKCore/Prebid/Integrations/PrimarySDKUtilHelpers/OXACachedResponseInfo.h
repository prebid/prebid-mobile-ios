//
//  OXACachedResponseInfo.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXADemandResponseInfo.h"
#import "OXATimerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXACachedResponseInfo : NSObject

@property (nonatomic, strong, nonnull, readonly) id<OXATimerInterface> expirationTimer;
@property (nonatomic, strong, nonnull, readonly) OXADemandResponseInfo *responseInfo;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithResponseInfo:(OXADemandResponseInfo *)responseInfo
                     expirationTimer:(id<OXATimerInterface>)expirationTimer NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
