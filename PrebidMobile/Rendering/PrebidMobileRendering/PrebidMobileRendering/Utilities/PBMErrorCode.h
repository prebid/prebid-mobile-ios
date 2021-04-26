//
//  PBMErrorCode.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBMErrorCode) {
    PBMErrorCodeGeneralLinear = 400,
    PBMErrorCodeFileNotFound = 401,
    PBMErrorCodeGeneralNonLinearAds = 500,
    PBMErrorCodeGeneral = 700,
    PBMErrorCodeUndefined = 900
};
