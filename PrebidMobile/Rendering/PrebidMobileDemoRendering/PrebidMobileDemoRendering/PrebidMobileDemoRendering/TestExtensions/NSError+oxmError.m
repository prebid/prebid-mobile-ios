//
//  NSError+oxmError.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "NSError+oxmError.h"
#import <OpenXApolloSDK/OXAPublicConstants.h>
#import <OpenXApolloSDK/OXAErrorCode.h>

@implementation NSError (oxmError)

+ (NSError *)oxmErrorWithDescription:(NSString *)description NS_SWIFT_NAME(oxmError(description:)) {
    
    return [NSError errorWithDomain:OXAErrorDomain
                               code:OXAErrorCodeGeneral
                           userInfo:@{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil)
                           }];
}

@end
