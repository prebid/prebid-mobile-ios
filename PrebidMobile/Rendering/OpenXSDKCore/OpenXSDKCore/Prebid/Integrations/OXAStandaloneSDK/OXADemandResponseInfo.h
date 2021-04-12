//
//  OXADemandResponseInfo.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABid.h"
#import "OXAFetchDemandResult.h"
#import <OpenXApolloSDK/OXANativeAdHandler.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXADemandResponseInfo : NSObject

@property (nonatomic, assign, readonly) OXAFetchDemandResult fetchDemandResult;

@property (nonatomic, copy, nullable, readonly) NSString *configId;
@property (nonatomic, strong, nullable, readonly) OXABid *bid;

- (instancetype)init NS_UNAVAILABLE;

- (void)getNativeAdWithCompletion:(OXANativeAdHandler)completion;

@end

NS_ASSUME_NONNULL_END
