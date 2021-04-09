//
//  MPFullscreenAdAdapter+MPFullscreenAdViewControllerDelegate.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPFullscreenAdAdapter.h"
#import "MPFullscreenAdViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdAdapter (AppearanceDelegate) <MPFullscreenAdViewControllerAppearanceDelegate>
@end

#pragma mark -

@interface MPFullscreenAdAdapter (WebAdDelegate) <MPFullscreenAdViewControllerWebAdDelegate>
@end

NS_ASSUME_NONNULL_END
