//
//  MPMRAIDInterstitialViewController.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInterstitialViewController.h"
#import "MPForceableOrientationProtocol.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPMRAIDInterstitialViewControllerDelegate;
@class MPAdConfiguration;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMRAIDInterstitialViewController : MPInterstitialViewController <MPForceableOrientationProtocol>

- (id)initWithAdConfiguration:(MPAdConfiguration *)configuration;
- (void)startLoading;

@end

