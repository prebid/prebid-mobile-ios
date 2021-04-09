//
//  OXMMRAIDConstants.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMMRAIDConstants.h"

//MARK: MRAID Actions
// Debug
OXMMRAIDAction const OXMMRAIDActionLog = @"log";
// MRAID 1
OXMMRAIDAction const OXMMRAIDActionOpen = @"open";
OXMMRAIDAction const OXMMRAIDActionClose = @"close";
OXMMRAIDAction const OXMMRAIDActionExpand = @"expand";
// MRAID 2
OXMMRAIDAction const OXMMRAIDActionResize = @"resize";
OXMMRAIDAction const OXMMRAIDActionStorePicture = @"storepicture";
OXMMRAIDAction const OXMMRAIDActionCreateCalendarEvent = @"createCalendarevent";
OXMMRAIDAction const OXMMRAIDActionPlayVideo = @"playVideo";
OXMMRAIDAction const OXMMRAIDActionOnOrientationPropertiesChanged = @"onOrientationPropertiesChanged";
// MRAID 3
OXMMRAIDAction const OXMMRAIDActionUnload = @"unload";
// ---- end MRAID Actions

// mraid enums and structs
OXMMRAIDPlacementType const OXMMRAIDPlacementTypeInline = @"inline";
OXMMRAIDPlacementType const OXMMRAIDPlacementTypeInterstitial = @"interstitial";

OXMMRAIDFeature const OXMMRAIDFeatureSMS           = @"sms";
OXMMRAIDFeature const OXMMRAIDFeaturePhone         = @"tel";
OXMMRAIDFeature const OXMMRAIDFeatureCalendar      = @"calendar";
OXMMRAIDFeature const OXMMRAIDFeatureSavePicture   = @"storePicture";
OXMMRAIDFeature const OXMMRAIDFeatureInlineVideo   = @"inlineVideo";
OXMMRAIDFeature const OXMMRAIDFeatureLocation      = @"location";
OXMMRAIDFeature const OXMMRAIDFeatureVPAID         = @"vpaid";

#pragma mark - OXMMRAIDParseKeys

@implementation OXMMRAIDParseKeys

+(NSString *)X {
    return @"x";
}

+(NSString *)Y {
    return @"y";
}

+(NSString *)WIDTH {
    return @"width";
}

+(NSString *)HEIGHT {
    return @"height";
}

+(NSString *)X_OFFSET {
    return @"offsetX";
}

+(NSString *)Y_OFFSET {
    return @"offsetY";
}

+(NSString *)ALLOW_OFFSCREEN {
    return @"allowOffscreen";
}

+(NSString *)FORCE_ORIENTATION {
    return @"forceOrientation";
}

@end


#pragma mark - OXMMRAIDValues

@implementation OXMMRAIDValues

+(NSString *)LANDSCAPE {
    return @"landscape";
}

+(NSString *)PORTRAIT {
    return @"portrait";
}

@end


#pragma mark - OXMMRAIDCloseButtonPosition

@implementation OXMMRAIDCloseButtonPosition

+(NSString *)BOTTOM_CENTER {
    return @"bottom-center";
}

+(NSString *)BOTTOM_LEFT {
    return @"bottom-left";
}

+(NSString *)BOTTOM_RIGHT {
    return @"bottom-right";
}

+(NSString *)CENTER {
    return @"center";
}

+(NSString *)TOP_CENTER {
    return @"top-center";
}

+(NSString *)TOP_LEFT {
    return @"top-left";
}

+(NSString *)TOP_RIGHT {
    return @"top-right";
}

@end


#pragma mark - OXMMRAIDCloseButtonSize

@implementation OXMMRAIDCloseButtonSize

+(float)WIDTH {
    return 50;
}

+(float)HEIGHT {
    return 50;
}

@end

#pragma mark - OXMMRAIDExpandProperties


@implementation OXMMRAIDExpandProperties

- (nonnull instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height {
    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
    }
    
    return self;
}

@end

#pragma mark OXMMRAIDResizeProperties

@implementation OXMMRAIDResizeProperties

- (nonnull instancetype)initWithWidth:(NSInteger)width
                               height:(NSInteger)height
                              offsetX:(NSInteger)offsetX
                              offsetY:(NSInteger)offsetY
                       allowOffscreen:(BOOL)allowOffscreen; {
    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
        self.offsetX = offsetX;
        self.offsetY = offsetY;
        self.allowOffscreen = allowOffscreen;
    }
    
    return self;
}

@end

#pragma mark - OXMMRAIDConstants

@implementation OXMMRAIDConstants

+(NSString *)mraidURLScheme {
    return @"mraid:";
}

+(NSArray<NSString *> *)allCases {
    static NSArray *_allCases;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _allCases = @[OXMMRAIDActionOpen,
                      OXMMRAIDActionExpand,
                      OXMMRAIDActionResize,
                      OXMMRAIDActionClose,
                      OXMMRAIDActionStorePicture,
                      OXMMRAIDActionCreateCalendarEvent,
                      OXMMRAIDActionPlayVideo,
                      OXMMRAIDActionLog,
                      OXMMRAIDActionOnOrientationPropertiesChanged,
                      OXMMRAIDActionUnload,
        ];
    });
    return _allCases;
}

@end
