//
//  PBMNativeEventType.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBMNativeEventType) {
    PBMNativeEventType_Impression = 1,          /// Impression
    PBMNativeEventType_MRC50 = 2,               /// Visible impression using MRC definition at 50% in view for 1 second
    PBMNativeEventType_MRC100 = 3,              /// 100% in view for 1 second (ie GroupM standard)
    PBMNativeEventType_Video50 = 4,             /// Visible impression for video using MRC definition at 50% in view for 2 seconds
    
    PBMNativeEventType_ExchangeSpecific = 500,  /// Reserved for Exchange specific usage numbered above 500
    PBMNativeEventType_OMID = 555,              /// Open Measurement event
};
