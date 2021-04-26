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

@property (nonatomic, strong, readonly) PBMRawBidResponse *rawResponse;

- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary;

@end

NS_ASSUME_NONNULL_END

