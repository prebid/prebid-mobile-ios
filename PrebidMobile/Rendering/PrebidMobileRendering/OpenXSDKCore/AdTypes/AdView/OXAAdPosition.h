//
//  OXAAdPosition.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - OXAAdPosition

//Ad position on screen
//Refer to table 5.4:
typedef NS_ENUM(NSInteger, OXAAdPosition) {
    OXAAdPosition_Undefined  = 0,
    OXAAdPosition_Header     = 4,
    OXAAdPosition_Footer     = 5,
    OXAAdPosition_Sidebar    = 6,
    OXAAdPosition_FullScreen = 7,
};
