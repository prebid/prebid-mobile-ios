//
//  NSDictionary+OXAORTBNativeExt.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (OXAORTBNativeExt)

- (nullable NSDictionary<NSString *, id> *)unserializedCopyWithError:(NSError * _Nullable __autoreleasing * _Nonnull)error;

@end

NS_ASSUME_NONNULL_END
