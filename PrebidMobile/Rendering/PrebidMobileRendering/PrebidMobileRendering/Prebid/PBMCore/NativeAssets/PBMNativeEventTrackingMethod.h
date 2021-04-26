//
//  PBMNativeEventTrackingMethod.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBMNativeEventTrackingMethod) {
    PBMNativeEventTrackingMethod_Img = 1, /// Image-pixel tracking - URL provided will be inserted as a 1x1 pixel at the time of the event.
    PBMNativeEventTrackingMethod_JS = 2, /// Javascript-based tracking - URL provided will be inserted as a js tag at the time of the event.
    
    PBMNativeEventTrackingMethod_ExchangeSpecific = 500, /// Could include custom measurement companies such as moat, doubleverify, IAS, etc - in this case additional elements will often be passed
};
