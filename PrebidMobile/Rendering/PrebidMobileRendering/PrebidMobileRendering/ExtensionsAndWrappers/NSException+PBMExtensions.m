//
//  NSException+OxmExtensions.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "NSException+PBMExtensions.h"
#import "PBMError.h"

@implementation NSException (PBMExtensions)

+ (nonnull NSException *)pbmException:(nonnull NSString*)message {
    NSString *desc = [NSString stringWithFormat:@"%@: %@", PBMErrorTypeInternalError, message];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:desc};
    return [NSException exceptionWithName:@"com.openx" reason:message userInfo:userInfo];
}


@end
