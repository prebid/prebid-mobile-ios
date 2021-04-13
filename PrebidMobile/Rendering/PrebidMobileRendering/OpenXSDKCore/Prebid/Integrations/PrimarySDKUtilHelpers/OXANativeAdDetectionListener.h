//
//  OXANativeAdDetectionListener.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeAd.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^OXANativeAdLoadedHandler)(OXANativeAd *nativeAd);
typedef void (^OXAPrimaryAdServerWinHandler)(void);
typedef void (^OXAInvalidNativeAdHandler)(NSError *error);

/// Immutable container for 3 mutually exclusive outcomes of an asynchronous native ad detection attempt.
@interface OXANativeAdDetectionListener : NSObject <NSCopying>

@property (nonatomic, copy, nullable, readonly) OXANativeAdLoadedHandler onNativeAdLoaded;
@property (nonatomic, copy, nullable, readonly) OXAPrimaryAdServerWinHandler onPrimaryAdWin;
@property (nonatomic, copy, nullable, readonly) OXAInvalidNativeAdHandler onNativeAdInvalid;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithNativeAdLoadedHandler:(nullable OXANativeAdLoadedHandler)onNativeAdLoaded
                               onPrimaryAdWin:(nullable OXAPrimaryAdServerWinHandler)onPrimaryAdWin
                            onNativeAdInvalid:(nullable OXAInvalidNativeAdHandler)onNativeAdInvalid NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
