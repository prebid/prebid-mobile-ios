//
//  VideoPlacementType.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

//Placement type for the video.
// See OpenRTB Table '5.9 Video Placement Types'
@objc public enum VideoPlacementType : Int {
    case undefined          = 0
    case inBanner           = 2 //Exists within a web banner that leverages the banner space to deliver a video experience as
                                            //opposed to another static or rich media format. The format relies on the existence of display
                                            //ad inventory on the page for its delivery.
    case inArticle          = 3 //Loads and plays dynamically between paragraphs of editorial content; existing as a standalone
                                            //branded message.
    case inFeed             = 4 //Found in content, social, or product feeds.
    case sliderOrFloating   = 5 //It is always on screen while displayed (i.e. cannot be scrolled out of view).
};
