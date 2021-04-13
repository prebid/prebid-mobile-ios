//
//  OXANativeAsset+InternalState.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <PrebidMobileRendering/OpenXApolloSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAsset (InternalState)

@property (nonatomic, strong, nullable, readwrite) NSNumber *assetID;
@property (nonatomic, strong) NSString *childType;
@property (nonatomic, copy, nullable, readonly) NSDictionary<NSString *, id> *childExt;

- (BOOL)setChildExt:(nullable NSDictionary<NSString *, id> *)childExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (nullable NSString *)toJsonStringWithError:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
