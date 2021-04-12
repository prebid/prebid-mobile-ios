//
//  OXAErrorCode.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXAErrorCode) {
    OXAErrorCodeGeneralLinear = 400,
    OXAErrorCodeFileNotFound = 401,
    OXAErrorCodeGeneralNonLinearAds = 500,
    OXAErrorCodeGeneral = 700,
    OXAErrorCodeUndefined = 900
};
