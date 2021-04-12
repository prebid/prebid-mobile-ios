//
//  OXANativeAdAssetBoxingError.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdAssetBoxingError : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, class, readonly) NSError *noDataInsideNativeAdMarkupAsset;
@property (nonatomic, class, readonly) NSError *noImageInsideNativeAdMarkupAsset;
@property (nonatomic, class, readonly) NSError *noTitleInsideNativeAdMarkupAsset;
@property (nonatomic, class, readonly) NSError *noVideoInsideNativeAdMarkupAsset;

@end

NS_ASSUME_NONNULL_END
