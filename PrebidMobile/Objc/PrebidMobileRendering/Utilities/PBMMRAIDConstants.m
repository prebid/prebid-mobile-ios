/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMMRAIDConstants.h"

//MARK: MRAID Actions
// Debug
PBMMRAIDAction const PBMMRAIDActionLog = @"log";
// MRAID 1
PBMMRAIDAction const PBMMRAIDActionOpen = @"open";
PBMMRAIDAction const PBMMRAIDActionClose = @"close";
PBMMRAIDAction const PBMMRAIDActionExpand = @"expand";
// MRAID 2
PBMMRAIDAction const PBMMRAIDActionResize = @"resize";
PBMMRAIDAction const PBMMRAIDActionStorePicture = @"storepicture";
PBMMRAIDAction const PBMMRAIDActionCreateCalendarEvent = @"createCalendarevent";
PBMMRAIDAction const PBMMRAIDActionPlayVideo = @"playVideo";
PBMMRAIDAction const PBMMRAIDActionOnOrientationPropertiesChanged = @"onOrientationPropertiesChanged";
// MRAID 3
PBMMRAIDAction const PBMMRAIDActionUnload = @"unload";
// ---- end MRAID Actions

// mraid enums and structs
PBMMRAIDPlacementType const PBMMRAIDPlacementTypeInline = @"inline";
PBMMRAIDPlacementType const PBMMRAIDPlacementTypeInterstitial = @"interstitial";

PBMMRAIDFeature const PBMMRAIDFeatureSMS           = @"sms";
PBMMRAIDFeature const PBMMRAIDFeaturePhone         = @"tel";
PBMMRAIDFeature const PBMMRAIDFeatureCalendar      = @"calendar";
PBMMRAIDFeature const PBMMRAIDFeatureSavePicture   = @"storePicture";
PBMMRAIDFeature const PBMMRAIDFeatureInlineVideo   = @"inlineVideo";
PBMMRAIDFeature const PBMMRAIDFeatureLocation      = @"location";
PBMMRAIDFeature const PBMMRAIDFeatureVPAID         = @"vpaid";

#pragma mark - PBMMRAIDParseKeys

@implementation PBMMRAIDParseKeys

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


#pragma mark - PBMMRAIDValues

@implementation PBMMRAIDValues

+(NSString *)LANDSCAPE {
    return @"landscape";
}

+(NSString *)PORTRAIT {
    return @"portrait";
}

@end


#pragma mark - PBMMRAIDCloseButtonPosition

@implementation PBMMRAIDCloseButtonPosition

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


#pragma mark - PBMMRAIDCloseButtonSize

@implementation PBMMRAIDCloseButtonSize

+(float)WIDTH {
    return 50;
}

+(float)HEIGHT {
    return 50;
}

@end

#pragma mark - PBMMRAIDExpandProperties


@implementation PBMMRAIDExpandProperties

- (nonnull instancetype)initWithWidth:(NSInteger)width height:(NSInteger)height {
    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
    }
    
    return self;
}

@end

#pragma mark PBMMRAIDResizeProperties

@implementation PBMMRAIDResizeProperties

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

#pragma mark - PBMMRAIDConstants

@implementation PBMMRAIDConstants

+(NSString *)mraidURLScheme {
    return @"mraid:";
}

+(NSArray<NSString *> *)allCases {
    static NSArray *_allCases;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _allCases = @[PBMMRAIDActionOpen,
                      PBMMRAIDActionExpand,
                      PBMMRAIDActionResize,
                      PBMMRAIDActionClose,
                      PBMMRAIDActionPlayVideo,
                      PBMMRAIDActionLog,
                      PBMMRAIDActionOnOrientationPropertiesChanged,
                      PBMMRAIDActionUnload,
        ];
    });
    return _allCases;
}

@end
