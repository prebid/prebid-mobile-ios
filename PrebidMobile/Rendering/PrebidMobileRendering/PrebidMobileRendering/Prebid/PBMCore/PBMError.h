//
//  PBMError.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMErrorCode.h"
#import "PBMErrorType.h"
#import "PBMFetchDemandResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMError : NSError

- (instancetype)init: (NSString*)message NS_SWIFT_NAME(init(message:));

// MARK: - Setup errors
@property (nonatomic, copy, nullable) NSString* message;

@property (nonatomic, class, readonly) NSError *requestInProgress;

// - Transport errors
//@property (nonatomic, class, readonly) NSError *demandTimedOut;

// MARK: - Known server text errors

@property (nonatomic, class, readonly) NSError *invalidAccountId;
@property (nonatomic, class, readonly) NSError *invalidConfigId;
@property (nonatomic, class, readonly) NSError *invalidSize;
//@property (nonatomic, class, readonly) NSError *prebidDemandNoBids;

+ (NSError *)prebidServerURLInvalid:(NSString *)url;

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

+ (PBMError *)errorWithDescription:(NSString *)description NS_SWIFT_NAME(error(description:));
+ (PBMError *)errorWithDescription:(NSString *)description statusCode:(PBMErrorCode)code NS_SWIFT_NAME(error(description:statusCode:));
+ (PBMError *)errorWithMessage:(NSString *)message type:(PBMErrorType)type NS_SWIFT_NAME(error(message:type:));

+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error description:(NSString *)description;
+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error description:(NSString *)description statusCode:(PBMErrorCode)code;
+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error message:(NSString *)message type:(PBMErrorType)type;

// MARK: - PBMFetchDemandResult parsing

+ (PBMFetchDemandResult)demandResultFromError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
