//
//  OXANativeEventTracker+InternalState.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PrebidMobileRendering/PrebidMobileRendering.h>

NS_ASSUME_NONNULL_BEGIN

@interface NativeEventTracker (InternalState)

- (nullable NSString *)toJsonStringWithError:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
