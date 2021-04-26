//
//  OXANativeEventTracker+InternalState.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <PrebidMobileRendering/PrebidMobileRenderingSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeEventTracker (InternalState)

- (nullable NSString *)toJsonStringWithError:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
