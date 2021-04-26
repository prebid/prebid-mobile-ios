//
//  PBMErrorFamily.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMErrorFamily.h"

NSString * const pbmErrorDomain = @"org.prebid.mobile.rendering";

NSInteger pbmErrorCode(PBMErrorFamily errorFamily, NSInteger errorCodeWithinFamily) {
    return -((NSInteger)errorFamily * 100 + errorCodeWithinFamily);
}
