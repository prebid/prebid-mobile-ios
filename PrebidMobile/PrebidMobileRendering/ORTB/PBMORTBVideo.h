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

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.7: Video

//This object represents an in-stream video impression. Many of the fields are non-essential for minimally viable transactions, but are included to offer fine control when needed. Video in OpenRTB generally assumes compliance with the VAST standard. As such, the notion of companion ads is supported by optionally including an array of Banner objects that define these companion ads.
@interface PBMORTBVideo : PBMORTBAbstract
    
//Content MIME types supported (e.g., “video/x-ms-wmv”, “video/mp4”).
@property (nonatomic, copy, nullable) NSArray<NSString *> *mimes;

//Int. Minimum video ad duration in seconds.
@property (nonatomic, strong, nullable) NSNumber *minduration;

//Int. Maximum video ad duration in seconds.
@property (nonatomic, strong, nullable) NSNumber *maxduration;

//Int. Array of supported video bid response protocols. At least one supported protocol must be specified in either the protocol or protocols attribute. See table 5.8:
//1) VAST 1.0
//2) VAST 2.0
//3) VAST 3.0
//4) VAST 1.0 Wrapper
//5) VAST 2.0 Wrapper
//6) VAST 3.0 Wrapper
//7) VAST 4.0
//8) VAST 4.0 Wrapper
//9) DAAST 1.0
//10) DAAST 1.0 Wrapper
//Note: since this is not settable by the pub, it can be an Int array instead of NSNumber.
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *protocols;

//NOTE: Deprecated in favor of protocols.
//Supported video protocol. Refer to List 5.8. At least one
//supported protocol must be specified in either the protocol
//or protocols attribute.
//protocol is not supported

//Int. Width of the video player in device independent pixels (DIPS).
@property (nonatomic, strong, nullable) NSNumber *w;

//Int. Height of the video player in device independent pixels (DIPS).
@property (nonatomic, strong, nullable) NSNumber *h;

//Int. Indicates the start delay in seconds for pre-roll, mid-roll, or
//post-roll ad placements. Refer to List 5.12 for additional
//generic values.
@property (nonatomic, strong, nullable) NSNumber *startdelay;

//Placement type for the impression. Refer to list 5.9:
//1) In-Stream: Played before, during or after the streaming video content that the consumer has requested (e.g., Pre-roll, Mid-roll, Post-roll).
//2) In-Banner: Exists within a web banner that leverages the banner space to deliver a video experience as opposed to another static or rich media format. The format relies on the existence of display ad inventory on the page for its delivery.
//3) In-Article: Loads and plays dynamically between paragraphs of editorial content; existing as a standalone branded message.
//4) In-Feed: Found in content, social, or product feeds.
//5) Interstitial/Slider/Floating: Covers the entire or a portion of screen area, but is always on screen while displayed (i.e. cannot be scrolled out of view). Note that a full-screen interstitial (e.g., in mobile) can be distinguished from a floating/slider unit by the imp.instl field.
//Note: PrebidMobile supports only Interstitial right now
@property (nonatomic, strong, nullable) NSNumber *placement;

//Placement type for the impression in accordance with updated IAB Digital Video Guidelines:
//1) Instream: Pre-roll, mid-roll, and post-roll ads that are played before, during or after the streaming video content that the consumer has requested. Instream video must be set to “sound on” by default at player start, or have explicitly clear user intent to watch the video content. While there may be other content surrounding the player, the video content must be the focus of the user’s visit. It should remain the primary content on the page and the only video player in-view capable of audio when playing. If the player converts to floating/sticky subsequent ad calls should accurately convey the updated player size.
//2) Accompanying Content: Pre-roll, mid-roll, and post-roll ads that are played before, during, or after streaming video content. The video player loads and plays before, between, or after paragraphs of text or graphical content, and starts playing only when it enters the viewport. Accompanying content should only start playback upon entering the viewport. It may convert to a floating/sticky player as it scrolls off the page.
//3) Interstitial:Video ads that are played without video content. During playback, it must be the primary focus of the page and take up the majority of the viewport and cannot be scrolled out of view. This can be in placements like in-app video or slideshows.
//4) No Content/Standalone: Video ads that are played without streaming video content. This can be in placements like slideshows, native feeds, in-content or sticky/floating.
@property (nonatomic, strong, nullable) NSNumber *plcmt;

//Int. Indicates if the impression must be linear, nonlinear, etc. If none specified, assume all are allowed.
//See table 5.7:
//Value Description
//1 Linear / In-Stream
//2 Non-Linear / Overlay
@property (nonatomic, strong, nullable) NSNumber *linearity;

//Indicates if the player will allow the video to be skipped,
//where 0 = no, 1 = yes.
//If a bidder sends markup/creative that is itself skippable, the
//Bid object should include the attr array with an element of
//16 indicating skippable video. Refer to List 5.3
//Note: Skip is not supported

//Videos of total duration greater than this number of seconds
//can be skippable; only applicable if the ad is skippable.
//Note: Skipmin is not supported

//Number of seconds a video must play before skipping is
//enabled; only applicable if the ad is skippable.
//Note: Skipafter is not supported

//If multiple ad impressions are offered in the same bid request, the sequence number will allow for the coordinated delivery of multiple creatives
//Note: Sequence is not supported

//Integer. Blocked creative attributes. Refer to list 5.3:
//Note: battr is not supported

//Int. Maximum extended video ad duration if extension is allowed. If blank or 0, extension is not allowed. If -1, extension is allowed, and there is no time limit imposed. If greater than 0, then the value represents the number of seconds of extended play supported beyond the maxduration value
//Note: Maxextended is not supported

//Int. Minimum bit rate in Kbps. Exchange may set this dynamically or universally across their set of publishers
@property (nonatomic, strong, nullable) NSNumber *minbitrate;

//Int. Maximum bit rate in Kbps. Exchange may set this dynamically åor universally across their set of publishers
@property (nonatomic, strong, nullable) NSNumber *maxbitrate;

//Indicates if letter-boxing of 4:3 content into a 16:9 window is allowed, where 0 = no, 1 = yes.
//Note: boxingallowed is not supported

//Int. Allowed playback methods. If none specified, assume all are allowed. Refer to table 5.9:
//5.9 Video Playback Methods
//The following table lists the various video playback methods.
//Value Description
//1 Auto-Play Sound On
//2 Auto-Play Sound Off
//3 Click-to-Play
//4 Mouse-Over
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *playbackmethod;

//The event that causes playback to end. Refer to List 5.11:
//1) On Video Completion or when Terminated by User
//2) On Leaving Viewport or when Terminated by User
//3) On Leaving Viewport Continues as a Floating/Slider Unit until Video Completion or when Terminated by User
//Note: PrebidMobile supports #2
@property (nonatomic, strong) NSNumber *playbackend;

//Int. Supported delivery methods (e.g., streaming, progressive). If none specified, assume all are supported.
//See table 5.15:
//1) Streaming
//2) Progressive
//3) Download
//Note: PrebidMobile supports Streaming and Download.
//Note: Since this is not settable by the pub we can use [Int] instead of [NSNumber].
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *delivery;

//Ad position on screen
//Refer to table 5.4:
//0) Unknown
//1) Above the Fold
//2) DEPRECATED - May or may not be initially visible depending on screen size/resolution.
//3) Below the Fold
//4) Header
//5) Footer
//6) Sidebar
//7) Full Screen
//Note: PrebidMobile supports Full Screen Only
@property (nonatomic, strong) NSNumber *pos;

//Note: companionad is not supported.
//Array of Banner objects if companion ads are available

//Int. List of supported API frameworks for this impression. If an API is not explicitly listed, it is assumed not to be supported
//Value Description
//1 VPAID 1.0
//2 VPAID 2.0
//3 MRAID-1
//4 ORMMA
//5 MRAID-2
//Note: PrebidMobile doesn't yet support Companion ads, so no apis are supported.
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *api;

//Int. Supported VAST companion ad types. Recommended if companion Banner objects are included via the companionad array.
//Refer to 5.12:
//1 Static Resource
//2 HTML Resource
//3 iframe Resource
//Note: companiontype is not supported.

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext is not supported.
    
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
