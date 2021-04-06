//
//  OXMError.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMError.h"
#import "OXAPublicConstants.h"
#import "OXMLog.h"

#pragma mark - Implementation

@implementation OXMError

+ (nonnull OXMError *)errorWithDescription:(nonnull NSString *)description {    
    return [OXMError errorWithDescription:description statusCode:OXAErrorCodeGeneral];
}

+ (OXMError *)errorWithDescription:(NSString *)description statusCode:(OXAErrorCode)code {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil)
                               };
    
    return [OXMError errorWithDomain:OXAErrorDomain
                                code:code
                            userInfo:userInfo];
}

+ (OXMError *)errorWithMessage:(NSString *)message type:(OXAErrorType)type {
    NSString *desc = [NSString stringWithFormat:@"%@: %@", type, message];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:desc};
    return [OXMError errorWithDomain:OXAErrorDomain code:0 userInfo:userInfo];
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error description:(NSString *)description {
    if (error != NULL) {
        *error = [OXMError errorWithDescription:description];
        OXMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error description:(NSString *)description statusCode:(OXAErrorCode)code {
    if (error != NULL) {
        *error = [OXMError errorWithDescription:description statusCode:code];
        OXMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error message:(NSString *)message type:(OXAErrorType)type {
    if (error != NULL) {
        *error = [OXMError errorWithMessage:message type:type];
        OXMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}

- (instancetype)init:(nonnull NSString*)msg {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(msg, nil)
                               };
    
    self = [super initWithDomain:OXAErrorDomain code:OXAErrorCodeGeneral userInfo:userInfo];
    if (self) {
        self.message = msg;
    }

    return self;
}

@end
