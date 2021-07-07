//
//  UIImage+MPAdditions.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * MPImageAsset;

/**
 This is the image asset for the Close button. The size of the image asset is 32x32.
 Per MRAID spec https://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf, page 31, the
 close event region should be 50x50 for expandable and fullscreen ads. On page 34, the 50x50 size
 applies to resized ads as well. For VAST (v3 ~ v4.2), close event region is not specified.
 */
extern MPImageAsset const kMPImageAssetCloseButton;

/**
 This is the image asset for the Skip button. The size of the image asset is 32x32, and the event
 region size is 50x50 (same as the Close button).
 */
extern MPImageAsset const kMPImageAssetSkipButton;

@interface UIImage (MPAdditions)

+ (UIImage *)imageForAsset:(MPImageAsset)asset;

@end

NS_ASSUME_NONNULL_END
