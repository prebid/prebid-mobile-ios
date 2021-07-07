//
//  MPFullscreenAdViewController+Image.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdViewController+Image.h"

#import "MPAdContainerView.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPFullscreenAdViewController+Web.h"
#import "UIView+MPAdditions.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

@implementation MPFullscreenAdViewController (Image)

- (void)prepareImageAdWithImageCreativeView:(MPImageCreativeView *)imageCreativeView {
    if (self.adContentType != MPAdContentTypeImage) {
        return;
    }

    imageCreativeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.adContainerView = [[MPAdContainerView alloc] initWithFrame:self.view.bounds imageCreativeView:imageCreativeView];
    self.adContainerView.countdownTimerDelegate = self;
    self.adContainerView.webAdDelegate = self; // Needed for close button to function
}

@end
