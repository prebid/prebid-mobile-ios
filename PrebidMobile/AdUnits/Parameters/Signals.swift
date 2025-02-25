/*   Copyright 2018-2019 Prebid.org, Inc.

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

/// A class containing constants related to OpenRTB signals.
///
/// This class provides static constants and values representing different
/// API frameworks, playback methods, protocols, start delays, and video
/// placement types as defined in the OpenRTB specification.
///
public class Signals: NSObject {
    
     ///# OpenRTB - API Frameworks #
     /// ```
     /// | Value | Description |
     /// |-------|-------------|
     /// | 1     | VPAID 1.0   |
     /// | 2     | VPAID 2.0   |
     /// | 3     | MRAID-1     |
     /// | 4     | ORMMA       |
     /// | 5     | MRAID-2     |
     /// | 6     | MRAID-3     |
     /// | 7     | OMID-1      |
     /// ```
    @objc(PBApi)
    public class Api: SingleContainerInt {
        
        /// VPAID 1.0
        @objc
        public static let VPAID_1 = Api(1)
        
        /// VPAID 2.0
        @objc
        public static let VPAID_2 = Api(2)
        
        /// MRAID-1
        @objc
        public static let MRAID_1 = Api(3)
        
        /// ORMMA
        @objc
        public static let ORMMA = Api(4)
        
        /// MRAID-2
        @objc
        public static let MRAID_2 = Api(5)
        
        /// MRAID-3
        @objc
        public static let MRAID_3 = Api(6)
        
        /// OMID-1
        @objc
        public static let OMID_1 = Api(7)
    }

    
    /// # OpenRTB - Playback Methods #
    /// ```
    /// | Value | Description                                              |
    /// |-------|----------------------------------------------------------|
    /// | 1     | Initiates on Page Load with Sound On                     |
    /// | 2     | Initiates on Page Load with Sound Off by Default         |
    /// | 3     | Initiates on Click with Sound On                         |
    /// | 4     | Initiates on Mouse-Over with Sound On                    |
    /// | 5     | Initiates on Entering Viewport with Sound On             |
    /// | 6     | Initiates on Entering Viewport with Sound Off by Default |
    /// ```
    @objc(PBPlaybackMethod)
    public class PlaybackMethod: SingleContainerInt {

        /// Initiates on Page Load with Sound On
        @objc
        public static let AutoPlaySoundOn = PlaybackMethod(1)
        
        /// Initiates on Page Load with Sound Off by Default
        @objc
        public static let AutoPlaySoundOff = PlaybackMethod(2)
        
        /// Initiates on Click with Sound On
        @objc
        public static let ClickToPlay = PlaybackMethod(3)
        
        /// Initiates on Mouse-Over with Sound On
        @objc
        public static let MouseOver = PlaybackMethod(4)
        
        /// Initiates on Entering Viewport with Sound On
        @objc
        public static let EnterSoundOn = PlaybackMethod(5)
        
        /// Initiates on Entering Viewport with Sound Off by Default
        @objc
        public static let EnterSoundOff = PlaybackMethod(6)

    }

    /// # OpenRTB - Protocols #
    /// ```
    /// | Value | Description       |
    /// |-------|-------------------|
    /// | 1     | VAST 1.0          |
    /// | 2     | VAST 2.0          |
    /// | 3     | VAST 3.0          |
    /// | 4     | VAST 1.0 Wrapper  |
    /// | 5     | VAST 2.0 Wrapper  |
    /// | 6     | VAST 3.0 Wrapper  |
    /// | 7     | VAST 4.0          |
    /// | 8     | VAST 4.0 Wrapper  |
    /// | 9     | DAAST 1.0         |
    /// | 10    | DAAST 1.0 Wrapper |
    /// ```
    @objc(PBProtocols)
    public class Protocols: SingleContainerInt {
        
        /// VAST 1.0
        @objc
        public static let VAST_1_0 = Protocols(1)
        
        /// VAST 2.0
        @objc
        public static let VAST_2_0 = Protocols(2)
        
        /// VAST 3.0
        @objc
        public static let VAST_3_0 = Protocols(3)
        
        /// VAST 1.0 Wrapper
        @objc
        public static let VAST_1_0_Wrapper = Protocols(4)
        
        /// VAST 2.0 Wrapper
        @objc
        public static let VAST_2_0_Wrapper = Protocols(5)
        
        /// VAST 3.0 Wrapper
        @objc
        public static let VAST_3_0_Wrapper = Protocols(6)
        
        /// VAST 4.0
        @objc
        public static let VAST_4_0 = Protocols(7)
        
        /// VAST 4.0 Wrapper
        @objc
        public static let VAST_4_0_Wrapper = Protocols(8)
        
        /// DAAST 1.0
        @objc
        public static let DAAST_1_0 = Protocols(9)
        
        /// DAAST 1.0 Wrapper
        @objc
        public static let DAAST_1_0_WRAPPER = Protocols(10)
        
    }

    /// # OpenRTB - Start Delay #
    /// ```
    /// | Value | Description                                      |
    /// |-------|--------------------------------------------------|
    /// | > 0   | Mid-Roll (value indicates start delay in second) |
    /// | 0     | Pre-Roll                                         |
    /// | -1    | Generic Mid-Roll                                 |
    /// | -2    | Generic Post-Roll                                |
    /// ```
    @objc(PBStartDelay)
    public class StartDelay: SingleContainerInt {
        
        /// Pre-Roll
        @objc
        public static let PreRoll = StartDelay(0)
        
        /// Generic Mid-Roll
        @objc
        public static let GenericMidRoll = StartDelay(-1)
        
        /// Generic Post-Roll
        @objc
        public static let GenericPostRoll = StartDelay(-2)
        
    }

    /// # OpenRTB - Video Placement Types #
    /// ```
    /// | Value | Description                  |
    /// |-------|------------------------------|
    /// | 1     | In-Stream                    |
    /// | 2     | In-Banner                    |
    /// | 3     | In-Article                   |
    /// | 4     | In-Feed                      |
    /// | 5     | Interstitial/Slider/Floating |
    /// ```
    @objc(PBPlacement)
    public class Placement: SingleContainerInt {
        
        /// In-Stream
        @objc
        public static let InStream = Placement(1)
        
        /// In-Banner
        @objc
        public static let InBanner = Placement(2)
        
        /// In-Article
        @objc
        public static let InArticle = Placement(3)
        
        /// In-Feed
        @objc
        public static let InFeed = Placement(4)
        
        /// Interstitial
        @objc
        public static let Interstitial = Placement(5)
        
        /// Slider
        @objc
        public static let Slider = Placement(5)
        
        /// Floating
        @objc
        public static let Floating = Placement(5)
        
        /// Helper function
        @objc public static func getPlacementByRawValue(_ value: Int) -> Signals.Placement? {
            switch value {
            case 1:
                return Signals.Placement.InStream
            case 2:
                return Signals.Placement.InBanner
            case 3:
                return Signals.Placement.InArticle
            case 4:
                return Signals.Placement.InFeed
            case 5:
                // TODO: Multiple cases for one raw value. Probable solution - make one case for interstitial, slider and floating
                return Signals.Placement.Interstitial
            default:
                return nil
            }
        }
    }
    
    /// # OpenRTB - Updated Video Placement Types #
    /// ```
    /// | Value | Description                  |
    /// |-------|------------------------------|
    /// | 1     | Instream                     |
    /// | 2     | Accompanying Content         |
    /// | 3     | Interstitial                 |
    /// | 4     | No Content/Standalone        |
    /// ```
    @objc(PBPlcmnt)
    public class Plcmnt: SingleContainerInt {
        
        /// Instream
        @objc
        public static let Instream = Plcmnt(1)
        
        /// AccompanyingContent
        @objc
        public static let AccompanyingContent = Plcmnt(2)
        
        /// Interstitial
        @objc
        public static let Interstitial = Plcmnt(3)
        
        /// NoContent
        @objc
        public static let NoContent = Plcmnt(4)
        
        /// Standalone
        @objc
        public static let Standalone = Plcmnt(4)
        
        /// Helper function
        @objc public static func getPlacementByRawValue(_ value: Int) -> Signals.Plcmnt? {
            switch value {
            case 1:
                return Signals.Plcmnt.Instream
            case 2:
                return Signals.Plcmnt.AccompanyingContent
            case 3:
                return Signals.Plcmnt.Interstitial
            case 4:
                // TODO: Multiple cases for one raw value. Probable solution - make one case for no content and standalone
                return Signals.Plcmnt.NoContent
            default:
                return nil
            }
        }
    }
    
    ///# OpenRTB - Creative Attributes #
    /// ```
    /// | Value | Description                                                                |
    /// |-------|----------------------------------------------------------------------------|
    /// | 1     | Audio Ad (Autoplay)                                                        |
    /// | 2     | Audio Ad (User Initiated)                                                  |
    /// | 3     | Expandable (Automatic)                                                     |
    /// | 4     | Expandable (User Initiated - Click)                                        |
    /// | 5     | Expandable (User Initiated - Rollover)                                     |
    /// | 6     | In-Banner Video Ad (Autoplay)                                              |
    /// | 7     | In-Banner Video Ad (User Initiated)                                        |
    /// | 8     | Pop (e.g., Over, Under, or Upon Exit)                                      |
    /// | 9     | Provocative or Suggestive Imagery                                          |
    /// | 10    | Shaky, Flashing, Flickering, Extreme Animation, Smileys                    |
    /// | 11    | Surveys                                                                    |
    /// | 12    | Text Only                                                                  |
    /// | 13    | User Interactive (e.g., Embedded Games)                                    |
    /// | 14    | Windows Dialog or Alert Style                                              |
    /// | 15    | Has Audio On/Off Button                                                    |
    /// | 16    | Ad Provides Skip Button (e.g. VPAID-rendered skip button on pre-roll video)|
    /// | 17    | Adobe Flash                                                                |
    /// ```
    @objc(PBCreativeAttribute)
    public class CreativeAttribute: SingleContainerInt {
        
        /// Audio Ad (Autoplay)
        @objc
        public static let AudioAd_Autoplay = CreativeAttribute(1)
        
        /// Audio Ad (User Initiated)
        @objc
        public static let AudioAd_UserInitiated = CreativeAttribute(2)
        
        /// Expandable (Automatic)
        @objc
        public static let Expandable_Automatic = CreativeAttribute(3)
        
        /// Expandable (User Initiated - Click)
        @objc
        public static let Expandable_Click = CreativeAttribute(4)
        
        /// Expandable (User Initiated - Rollover)
        @objc
        public static let Expandable_Rollover = CreativeAttribute(5)
        
        /// In-Banner Video Ad (Autoplay)
        @objc
        public static let InBanner_Autoplay = CreativeAttribute(6)
        
        /// In-Banner Video Ad (User Initiated)
        @objc
        public static let InBanner_UserInitiated = CreativeAttribute(7)
        
        /// Pop (e.g., Over, Under, or Upon Exit)
        @objc
        public static let Pop = CreativeAttribute(8)
        
        /// Provocative
        @objc
        public static let Provocative = CreativeAttribute(9)
        
        /// Suggestive Imagery
        @objc
        public static let SuggestiveImagery = CreativeAttribute(9)
        
        /// Shaky
        @objc
        public static let Shaky = CreativeAttribute(10)

        /// Flashing
        @objc
        public static let Flashing = CreativeAttribute(10)

        /// Flickering
        @objc
        public static let Flickering = CreativeAttribute(10)

        /// Extreme Animation
        @objc
        public static let ExtremeAnimation = CreativeAttribute(10)

        /// Smileys
        @objc
        public static let Smileys = CreativeAttribute(10)

        /// Surveys
        @objc
        public static let Surveys = CreativeAttribute(11)
        
        /// Text Only
        @objc
        public static let TextOnly = CreativeAttribute(12)
        
        /// User Interactive (e.g., Embedded Games)
        @objc
        public static let UserInteractive = CreativeAttribute(13)
        
        /// Windows Dialog
        @objc
        public static let WindowsDialog = CreativeAttribute(14)
        
        /// Alert Style
        @objc
        public static let AlertStyle = CreativeAttribute(14)
        
        /// Has Audio On/Off Button
        @objc
        public static let AudioButton = CreativeAttribute(15)
        
        /// Ad Provides Skip Button (e.g. VPAID-rendered skip button on pre-roll video)
        @objc
        public static let SkipButton = CreativeAttribute(16)
        
        /// Adobe Flash
        @objc
        public static let AdobeFlash = CreativeAttribute(17)
        
        /// Helper function
        @objc public static func getCreativeAttributeByRawValue(_ value: Int) -> Signals.CreativeAttribute? {
            switch value {
            case 1:
                return Signals.CreativeAttribute.AudioAd_Autoplay
            case 2:
                return Signals.CreativeAttribute.AudioAd_UserInitiated
            case 3:
                return Signals.CreativeAttribute.Expandable_Automatic
            case 4:
                return Signals.CreativeAttribute.Expandable_Click
            case 5:
                return Signals.CreativeAttribute.Expandable_Rollover
            case 6:
                return Signals.CreativeAttribute.InBanner_Autoplay
            case 7:
                return Signals.CreativeAttribute.InBanner_UserInitiated
            case 8:
                return Signals.CreativeAttribute.Pop
            case 9:
                return Signals.CreativeAttribute.Provocative
            case 10:
                return Signals.CreativeAttribute.Shaky
            case 11:
                return Signals.CreativeAttribute.Surveys
            case 12:
                return Signals.CreativeAttribute.TextOnly
            case 13:
                return Signals.CreativeAttribute.UserInteractive
            case 14:
                return Signals.CreativeAttribute.AlertStyle
            case 15:
                return Signals.CreativeAttribute.AudioButton
            case 16:
                return Signals.CreativeAttribute.SkipButton
            case 17:
                return Signals.CreativeAttribute.AdobeFlash
            default:
                return nil
            }
        }
    }
}
