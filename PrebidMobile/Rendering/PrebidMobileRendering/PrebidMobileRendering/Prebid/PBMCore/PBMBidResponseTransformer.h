//
//  PBMBidResponseTransformer.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BidResponse;
@class PBMServerResponse;

@interface PBMBidResponseTransformer : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;

+ (BidResponse * _Nullable)transformResponse:(PBMServerResponse * _Nonnull)response error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
