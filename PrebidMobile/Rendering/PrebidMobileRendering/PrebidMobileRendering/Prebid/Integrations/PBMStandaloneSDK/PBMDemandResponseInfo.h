//
//  PBMDemandResponseInfo.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBid.h"
#import "PBMFetchDemandResult.h"
#import <PrebidMobileRendering/PBMNativeAdHandler.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMDemandResponseInfo : NSObject

@property (nonatomic, assign, readonly) PBMFetchDemandResult fetchDemandResult;

@property (nonatomic, copy, nullable, readonly) NSString *configId;
@property (nonatomic, strong, nullable, readonly) PBMBid *bid;

- (instancetype)init NS_UNAVAILABLE;

- (void)getNativeAdWithCompletion:(PBMNativeAdHandler)completion;

@end

NS_ASSUME_NONNULL_END
