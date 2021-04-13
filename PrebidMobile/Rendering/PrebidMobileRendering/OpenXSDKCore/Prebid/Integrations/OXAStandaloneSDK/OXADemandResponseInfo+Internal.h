//
//  OXADemandResponseInfo+Internal.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXADemandResponseInfo.h"

#import "OXAAdMarkupStringHandler.h"
#import "OXAWinNotifierBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXADemandResponseInfo ()

@property (nonatomic, copy, readonly) OXAWinNotifierBlock winNotifierBlock;

- (instancetype)initWithFetchDemandResult:(OXAFetchDemandResult)fetchDemandResult
                                      bid:(nullable OXABid *)bid
                                 configId:(nullable NSString *)configId
                         winNotifierBlock:(OXAWinNotifierBlock)winNotifierBlock NS_DESIGNATED_INITIALIZER;

- (void)getAdMarkupStringWithCompletion:(OXAAdMarkupStringHandler)completion;

@end

NS_ASSUME_NONNULL_END
