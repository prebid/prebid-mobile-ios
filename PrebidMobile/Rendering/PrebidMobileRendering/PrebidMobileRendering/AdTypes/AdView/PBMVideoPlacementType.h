//
//  PBMVideoPlacementType.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#pragma mark - PBMVideoPlacementType

//Placement type for the video.
// See OpenRTB Table '5.9 Video Placement Types'
typedef NS_ENUM(NSInteger, PBMVideoPlacementType) {
    PBMVideoPlacementType_Undefined    = 0,
    PBMVideoPlacementType_InBanner     = 2, //Exists within a web banner that leverages the banner space to deliver a video experience as
                                            //opposed to another static or rich media format. The format relies on the existence of display
                                            //ad inventory on the page for its delivery.
    PBMVideoPlacementType_InArticle    = 3, //Loads and plays dynamically between paragraphs of editorial content; existing as a standalone
                                            //branded message.
    PBMVideoPlacementType_InFeed       = 4, //Found in content, social, or product feeds.
    PBMVideoPlacementType_SliderOrFloating = 5, //It is always on screen while displayed (i.e. cannot be scrolled out of view).
};
