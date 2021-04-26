//
//  PBMNativeAdAsset+FromMarkup.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdAsset.h"
#import "PBMNativeAdMarkupAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdAsset ()

/// Link object for call to actions.
/// The link object applies if the asset item is activated (clicked).
/// If there is no link object on the asset, the parent link object on the bid response applies.
@property (nonatomic, strong, nullable, readonly) PBMNativeAdMarkupLink *link;

- (nullable instancetype)initWithNativeAdMarkupAsset:(PBMNativeAdMarkupAsset *)nativeAdMarkupAsset
                                               error:(NSError * _Nullable __autoreleasing * _Nullable)error;


@end

NS_ASSUME_NONNULL_END
