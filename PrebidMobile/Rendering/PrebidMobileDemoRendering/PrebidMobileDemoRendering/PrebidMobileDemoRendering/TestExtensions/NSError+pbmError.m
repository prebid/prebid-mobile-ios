//
//  NSError+oxmError.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "NSError+pbmError.h"
#import <PrebidMobileRendering/PBMPublicConstants.h>
#import <PrebidMobileRendering/PBMErrorCode.h>

@implementation NSError (pbmError)

+ (NSError *)pbmErrorWithDescription:(NSString *)description NS_SWIFT_NAME(pbmError(description:)) {
    
    return [NSError errorWithDomain:PBMErrorDomain
                               code:PBMErrorCodeGeneral
                           userInfo:@{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil)
                           }];
}

@end
