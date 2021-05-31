//
//  PBMBidRequesterProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

@class BidResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMBidRequesterProtocol <NSObject>

- (void)requestBidsWithCompletion:(void (^)(BidResponse * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
