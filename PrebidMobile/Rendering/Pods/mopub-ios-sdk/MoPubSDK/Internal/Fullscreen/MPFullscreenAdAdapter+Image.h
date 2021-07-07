//
//  MPFullscreenAdAdapter+Image.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdAdapter (Image)

/**
 Loads an image ad from the @c configuation property. Downloads the image asynchronously,
 Renders into an image view, preps the @c viewController, and notifies @c delegate when all the
 preparation is done. If the @c configuation isn't configured for a static image ad, or if the
 image cannot be downloaded, the @c delegate object will be notified of failure.
 */
- (void)loadImageAd;

@end

NS_ASSUME_NONNULL_END
