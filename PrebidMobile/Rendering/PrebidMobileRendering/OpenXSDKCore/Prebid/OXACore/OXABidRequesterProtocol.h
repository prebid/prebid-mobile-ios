//
//  OXABidRequesterProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

@class OXABidResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol OXABidRequesterProtocol <NSObject>

- (void)requestBidsWithCompletion:(void (^)(OXABidResponse * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
