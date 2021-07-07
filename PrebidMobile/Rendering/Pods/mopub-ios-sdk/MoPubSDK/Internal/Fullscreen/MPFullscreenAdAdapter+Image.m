//
//  MPFullscreenAdAdapter+Image.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdAdapter+Image.h"

#import "MPError.h"
#import "MPFullscreenAdAdapter+MPFullscreenAdViewControllerDelegate.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Reward.h"
#import "MPFullscreenAdViewController+Image.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

// This interface must be defined above the MPFullscreenAdAdapter (Image) implementation
// so that it can see that MPFullscreenAdAdapter conforms to MPImageLoaderDelegate and
// MPImageCreativeViewDelegate.
@interface MPFullscreenAdAdapter (ImagePrivate) <MPImageLoaderDelegate, MPImageCreativeViewDelegate>
@end

@implementation MPFullscreenAdAdapter (Image)

- (void)loadImageAd {
    // Make sure we have a valid image URL
    NSURL *imageURL = self.configuration.imageCreativeData.imageURL;
    if (imageURL == nil) {
        NSError *parsingError = [NSError errorWithCode:MOPUBErrorUnableToParseJSONAdResponse];
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:parsingError];
        return;
    }

    // Init the image loader
    self.imageLoader = [[MPImageLoader alloc] init];
    self.imageLoader.delegate = self;

    // Init the image creative view
    self.imageCreativeView = [[MPImageCreativeView alloc] init];
    self.imageCreativeView.delegate = self;

    // Load the image creative URL into the image creative view
    [self.imageLoader loadImageForURL:imageURL
                        intoImageView:self.imageCreativeView];
}

@end

@implementation MPFullscreenAdAdapter (ImagePrivate)

#pragma mark - MPImageLoaderDelegate

- (BOOL)nativeAdViewInViewHierarchy {
    // @c MPImageLoader was built for Native Table/Collection view placer with the idea
    // that some requests should be canceled/not be rendered if the view that the image
    // is being rendered to is not in the view hierarchy. This method is what determines
    // if the view is in the hierarchy from @c MPImageLoader's perspective.

    // That logic isn't relevant here, so always return that the view is in the hierarchy
    // so the image always gets downloaded and rendered into the view.
    return YES;
}

- (void)imageLoader:(MPImageLoader *)imageLoader didLoadImageIntoImageView:(UIImageView *)imageView {
    // Loaded image successfully
    // Now, init the view controller and pass the image view on to the view controller.
    self.viewController = [[MPFullscreenAdViewController alloc] initWithAdContentType:MPAdContentTypeImage];
    [self.viewController prepareImageAdWithImageCreativeView:self.imageCreativeView];
    self.viewController.appearanceDelegate = self;
    self.viewController.countdownTimerDelegate = self;

    if (self.isRewardExpected) {
        // If a reward is expected, set up the view controller with the countdown duration
        [self.viewController setRewardCountdownDuration:self.rewardCountdownDuration];
    }
    else {
        // If a reward is not expected, enable click immediately on the image creative view
        [self.imageCreativeView enableClick];
    }

    self.hasAdAvailable = YES;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)imageLoaderDidFailToLoadImageWithError:(NSError *)error {
    // Image did not load successfully, so fail the ad load.
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

#pragma mark - MPImageCreativeViewDelegate

- (void)imageCreativeViewWasClicked:(MPImageCreativeView *)imageCreativeView {
    MPAdConfiguration *configuration = self.configuration;
    MPImageCreativeData *creativeData = configuration.imageCreativeData;

    // No-op (i.e., do not fire trackers) if there's no click destination
    if (creativeData.clickthroughURL == nil) {
        return;
    }

    // Track the click
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];

    // Navigate to clickthrough destination
    [self.adDestinationDisplayAgent displayDestinationForURL:creativeData.clickthroughURL
                                 skAdNetworkClickthroughData:configuration.skAdNetworkClickthroughData];
}

@end
