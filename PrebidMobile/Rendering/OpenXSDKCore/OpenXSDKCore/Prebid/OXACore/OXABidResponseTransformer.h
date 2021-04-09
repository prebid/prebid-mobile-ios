//
//  OXABidResponseTransformer.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXABidResponse;
@class OXMServerResponse;

@interface OXABidResponseTransformer : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;

+ (OXABidResponse * _Nullable)transformResponse:(OXMServerResponse * _Nonnull)response error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
