//
//  MPFullscreenAdViewController+Image.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdViewController.h"

@class MPImageCreativeView;

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdViewController (Image)

/**
 Prepares a freshly created @c MPFullscreenViewController instance for an ad with an
 image creative in a native view, using the @c MPCreativeImageView that is passed in.
 @c imageCreativeView is expected to already be prepped with the image ad when this method
 is called.

 @param imageCreativeView the @c MPImageCreativeView instance to be rendered with the
 image ad prepped.
 */
- (void)prepareImageAdWithImageCreativeView:(MPImageCreativeView *)imageCreativeView;

@end

NS_ASSUME_NONNULL_END
