//
//  PBMNativeAdDetectionListener.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^PBMNativeAdLoadedHandler)(PBMNativeAd *nativeAd);
typedef void (^PBMPrimaryAdServerWinHandler)(void);
typedef void (^PBMInvalidNativeAdHandler)(NSError *error);

/// Immutable container for 3 mutually exclusive outcomes of an asynchronous native ad detection attempt.
@interface PBMNativeAdDetectionListener : NSObject <NSCopying>

@property (nonatomic, copy, nullable, readonly) PBMNativeAdLoadedHandler onNativeAdLoaded;
@property (nonatomic, copy, nullable, readonly) PBMPrimaryAdServerWinHandler onPrimaryAdWin;
@property (nonatomic, copy, nullable, readonly) PBMInvalidNativeAdHandler onNativeAdInvalid;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithNativeAdLoadedHandler:(nullable PBMNativeAdLoadedHandler)onNativeAdLoaded
                               onPrimaryAdWin:(nullable PBMPrimaryAdServerWinHandler)onPrimaryAdWin
                            onNativeAdInvalid:(nullable PBMInvalidNativeAdHandler)onNativeAdInvalid NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
