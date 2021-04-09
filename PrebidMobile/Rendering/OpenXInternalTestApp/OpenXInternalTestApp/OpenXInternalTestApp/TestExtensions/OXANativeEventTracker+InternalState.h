//
//  OXANativeEventTracker+InternalState.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <OpenXApolloSDK/OpenXApolloSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeEventTracker (InternalState)

- (nullable NSString *)toJsonStringWithError:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
