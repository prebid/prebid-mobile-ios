//
//  OXABidResponse+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABidResponse.h"
#import "OXARawBidResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXABidResponse()

- (instancetype)initWithRawBidResponse:(OXARawBidResponse *)rawBidResponse NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

