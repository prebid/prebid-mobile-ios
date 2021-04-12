//
//  OXANativeEventType.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXANativeEventType) {
    OXANativeEventType_Impression = 1,          /// Impression
    OXANativeEventType_MRC50 = 2,               /// Visible impression using MRC definition at 50% in view for 1 second
    OXANativeEventType_MRC100 = 3,              /// 100% in view for 1 second (ie GroupM standard)
    OXANativeEventType_Video50 = 4,             /// Visible impression for video using MRC definition at 50% in view for 2 seconds
    
    OXANativeEventType_ExchangeSpecific = 500,  /// Reserved for Exchange specific usage numbered above 500
    OXANativeEventType_OMID = 555,              /// Open Measurement event
};
