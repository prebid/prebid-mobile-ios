//
//  OXAErrorFamily.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAErrorFamily.h"

NSString * const oxaErrorDomain = @"com.openx.sdk.prebid";

NSInteger oxaErrorCode(OXAErrorFamily errorFamily, NSInteger errorCodeWithinFamily) {
    return -((NSInteger)errorFamily * 100 + errorCodeWithinFamily);
}
