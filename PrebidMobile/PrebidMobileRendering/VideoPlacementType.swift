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
