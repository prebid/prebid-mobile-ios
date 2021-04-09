//
//  MPFullscreenAdViewController+MPForceableOrientationProtocol.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdViewController+MPForceableOrientationProtocol.h"
#import "MPFullscreenAdViewController+Private.h"

@implementation MPFullscreenAdViewController (MPForceableOrientationProtocol)

// custom `supportedOrientationMask` getter
- (UIInterfaceOrientationMask)supportedOrientationMask {
    return self._supportedOrientationMask;
}

// custom `supportedOrientationMask` setter
- (void)setSupportedOrientationMask:(UIInterfaceOrientationMask)supportedOrientationMask {
    self._supportedOrientationMask = supportedOrientationMask;
        
    // This should be called whenever the return value of -supportedInterfaceOrientations changes.
    // Since the return value is based on _supportedOrientationMask, we do that here. Prevents
    // possible rotation bugs.
    [UIViewController attemptRotationToDeviceOrientation];
}

@end
