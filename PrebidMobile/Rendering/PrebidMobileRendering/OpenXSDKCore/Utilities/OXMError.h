//
//  OXMError.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXAErrorCode.h"
#import "OXAErrorType.h"

NS_ASSUME_NONNULL_BEGIN
@interface OXMError : NSError
@property (nonatomic, copy, nullable) NSString* message;

+ (OXMError *)errorWithDescription:(NSString *)description NS_SWIFT_NAME(error(description:));
+ (OXMError *)errorWithDescription:(NSString *)description statusCode:(OXAErrorCode)code NS_SWIFT_NAME(error(description:statusCode:));
+ (OXMError *)errorWithMessage:(NSString *)message type:(OXAErrorType)type NS_SWIFT_NAME(error(message:type:));

+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error description:(NSString *)description;
+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error description:(NSString *)description statusCode:(OXAErrorCode)code;
+ (BOOL)createError:(NSError* _Nullable __autoreleasing * _Nullable)error message:(NSString *)message type:(OXAErrorType)type;

- (instancetype)init: (NSString*)message NS_SWIFT_NAME(init(message:));

@end
NS_ASSUME_NONNULL_END
