//
//  MPFullscreenAdViewController+MPForceableOrientationProtocol.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPForceableOrientationProtocol.h"
#import "MPFullscreenAdViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdViewController (MPForceableOrientationProtocol) <MPForceableOrientationProtocol>

@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask; // custom getter and setter

@end

NS_ASSUME_NONNULL_END
