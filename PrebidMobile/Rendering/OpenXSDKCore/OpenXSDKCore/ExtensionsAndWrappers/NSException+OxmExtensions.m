//
//  NSException+OxmExtensions.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "NSException+OxmExtensions.h"
#import "OXMError.h"

@implementation NSException (OxmExtensions)

+ (nonnull NSException *)oxmException:(nonnull NSString*)message {
    NSString *desc = [NSString stringWithFormat:@"%@: %@", OXAErrorTypeInternalError, message];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:desc};
    return [NSException exceptionWithName:@"com.openx" reason:message userInfo:userInfo];
}


@end
