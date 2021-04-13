//
//  OXAAdFormat.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - OXMAdFormat

/**
 Determines the type of an AdIndentifier Object

 - OXMAdFormatDisplay: use  Ad Unit ID
 - OXMAdFormatVideo: use vastURL
 */
typedef NS_ENUM(NSInteger, OXAAdFormat) {
    OXAAdFormatDisplay,
    OXAAdFormatVideo,
    //OXAAdFormatNative,
    //OXAAdFormatMultiformat,
};
