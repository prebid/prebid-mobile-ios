//
//  OXAError.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "OXAFetchDemandResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAError : NSObject

- (instancetype)init NS_UNAVAILABLE;

// MARK: - Setup errors

@property (nonatomic, class, readonly) NSError *requestInProgress;

// - Transport errors
//@property (nonatomic, class, readonly) NSError *demandTimedOut;

// MARK: - Known server text errors

@property (nonatomic, class, readonly) NSError *invalidAccountId;
@property (nonatomic, class, readonly) NSError *invalidConfigId;
@property (nonatomic, class, readonly) NSError *invalidSize;
//@property (nonatomic, class, readonly) NSError *prebidDemandNoBids;

// MARK: - Unknown server text errors

+ (NSError *)serverError:(NSString *)errorBody;

// MARK: - Response processing errors

@property (nonatomic, class, readonly) NSError *jsonDictNotFound;
@property (nonatomic, class, readonly) NSError *responseDeserializationFailed;
@property (nonatomic, class, readonly) NSError *noEventForNativeAdMarkupEventTracker;
@property (nonatomic, class, readonly) NSError *noMethodForNativeAdMarkupEventTracker;
@property (nonatomic, class, readonly) NSError *noUrlForNativeAdMarkupEventTracker;

// MARK: - Integration layer errors
@property (nonatomic, class, readonly) NSError *noNativeCreative;
@property (nonatomic, class, readonly) NSError *noWinningBid;
@property (nonatomic, class, readonly) NSError *noVastTagInMediaData;

// MARK: - SDK Misuse Errors
@property (nonatomic, class, readonly) NSError *replacingMediaDataInMediaView;

// MARK: - OXAFetchDemandResult parsing

+ (OXAFetchDemandResult)demandResultFromError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
