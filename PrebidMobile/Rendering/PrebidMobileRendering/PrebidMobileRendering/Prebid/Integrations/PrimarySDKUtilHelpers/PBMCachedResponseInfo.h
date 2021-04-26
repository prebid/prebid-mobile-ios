//
//  PBMCachedResponseInfo.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMDemandResponseInfo.h"
#import "PBMTimerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMCachedResponseInfo : NSObject

@property (nonatomic, strong, nonnull, readonly) id<PBMTimerInterface> expirationTimer;
@property (nonatomic, strong, nonnull, readonly) PBMDemandResponseInfo *responseInfo;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithResponseInfo:(PBMDemandResponseInfo *)responseInfo
                     expirationTimer:(id<PBMTimerInterface>)expirationTimer NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
