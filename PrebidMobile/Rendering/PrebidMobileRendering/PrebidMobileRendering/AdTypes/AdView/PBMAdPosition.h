//
//  PBMAdPosition.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - PBMAdPosition

//Ad position on screen
//Refer to table 5.4:
typedef NS_ENUM(NSInteger, PBMAdPosition) {
    PBMAdPosition_Undefined  = 0,
    PBMAdPosition_Header     = 4,
    PBMAdPosition_Footer     = 5,
    PBMAdPosition_Sidebar    = 6,
    PBMAdPosition_FullScreen = 7,
};
