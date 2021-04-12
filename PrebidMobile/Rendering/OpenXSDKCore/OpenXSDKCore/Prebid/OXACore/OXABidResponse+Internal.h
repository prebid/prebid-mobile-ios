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

@property (nonatomic, strong, readonly) OXARawBidResponse *rawResponse;

- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary;

@end

NS_ASSUME_NONNULL_END

