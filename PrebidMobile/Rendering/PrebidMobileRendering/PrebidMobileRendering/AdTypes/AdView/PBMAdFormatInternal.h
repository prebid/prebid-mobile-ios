//
//  PBMAdFormat.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PrebidMobileRendering/PBMAdFormat.h>

#pragma mark - PBMAdFormatInternal

/**
 Determines the type of an AdIndentifier Object

 - PBMAdFormatDisplayInternal: use  Ad Unit ID
 - PBMAdFormatVideoInternal: use vastURL
 */
typedef NS_ENUM(NSInteger, PBMAdFormatInternal) {
    PBMAdFormatDisplayInternal = PBMAdFormatDisplay,
    PBMAdFormatVideoInternal = PBMAdFormatVideo,
    PBMAdFormatNativeInternal,
    //PBMAdFormatMultiformatInternal,
};
