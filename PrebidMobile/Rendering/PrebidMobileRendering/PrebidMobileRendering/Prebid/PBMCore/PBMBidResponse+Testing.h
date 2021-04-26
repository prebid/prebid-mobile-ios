//
//  PBMBidResponse+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidResponse.h"
#import "PBMRawBidResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMBidResponse()

- (instancetype)initWithRawBidResponse:(PBMRawBidResponse *)rawBidResponse NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

