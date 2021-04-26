//
//  PBMAdFormat.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - PBMAdFormat

/**
 Determines the type of an AdIndentifier Object

 - PBMAdFormatDisplay: use  Ad Unit ID
 - PBMAdFormatVideo: use vastURL
 */
typedef NS_ENUM(NSInteger, PBMAdFormat) {
    PBMAdFormatDisplay,
    PBMAdFormatVideo,
    //PBMAdFormatNative,
    //PBMAdFormatMultiformat,
};
