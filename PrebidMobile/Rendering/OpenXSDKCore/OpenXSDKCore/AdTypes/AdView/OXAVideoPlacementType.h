//
//  OXAVideoPlacementType.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#pragma mark - OXAVideoPlacementType

//Placement type for the video.
// See OpenRTB Table '5.9 Video Placement Types'
typedef NS_ENUM(NSInteger, OXAVideoPlacementType) {
    OXAVideoPlacementType_Undefined    = 0,
    OXAVideoPlacementType_InBanner     = 2, //Exists within a web banner that leverages the banner space to deliver a video experience as
                                            //opposed to another static or rich media format. The format relies on the existence of display
                                            //ad inventory on the page for its delivery.
    OXAVideoPlacementType_InArticle    = 3, //Loads and plays dynamically between paragraphs of editorial content; existing as a standalone
                                            //branded message.
    OXAVideoPlacementType_InFeed       = 4, //Found in content, social, or product feeds.
    OXAVideoPlacementType_SliderOrFloating = 5, //It is always on screen while displayed (i.e. cannot be scrolled out of view).
};
