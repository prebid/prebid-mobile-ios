//
//  PBMDemandResponseInfo+Internal.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMDemandResponseInfo.h"

#import "PBMAdMarkupStringHandler.h"
#import "PBMWinNotifierBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMDemandResponseInfo ()

@property (nonatomic, copy, readonly) PBMWinNotifierBlock winNotifierBlock;

- (instancetype)initWithFetchDemandResult:(PBMFetchDemandResult)fetchDemandResult
                                      bid:(nullable PBMBid *)bid
                                 configId:(nullable NSString *)configId
                         winNotifierBlock:(PBMWinNotifierBlock)winNotifierBlock NS_DESIGNATED_INITIALIZER;

- (void)getAdMarkupStringWithCompletion:(PBMAdMarkupStringHandler)completion;

@end

NS_ASSUME_NONNULL_END
