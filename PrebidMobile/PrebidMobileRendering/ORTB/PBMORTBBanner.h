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

@class PBMORTBFormat;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.6: Banner

//This object represents the most general type of impression. Although the term “banner” may have very
//specific meaning in other contexts, here it can be many things including a simple static image, an
//expandable ad unit, or even in-banner video (refer to the Video object in Section 3.2.7 for the more
//generalized and full featured video ad units). An array of Banner objects can also appear within the
//Video to describe optional companion ads defined in the VAST specification.
//The presence of a Banner as a subordinate of the Imp object indicates that this impression is offered as
//a banner type impression. At the publisher’s discretion, that same impression may also be offered as
//video, audio, and/or native by also including as Imp subordinates objects of those types. However, any
//given bid for the impression must conform to one of the offered types.
@interface PBMORTBBanner : PBMORTBAbstract
    
//Array of format objects (Section 3.2.10) representing the
//banner sizes permitted. If none are specified, then use of the
//h and w attributes is highly recommended.
@property (nonatomic, copy) NSArray<PBMORTBFormat *> *format;

//Exact width in device independent pixels (DIPS);
//recommended if no format objects are specified.
//Note: w is not supported.

//Exact height in device independent pixels (DIPS);
//recommended if no format objects are specified
//Note: h is not supported.

//NOTE: Deprecated in favor of the format array.
//Maximum width in device independent pixels (DIPS).
//Note: wmax is not supported.

//NOTE: Deprecated in favor of the format array.
//Maximum height in device independent pixels (DIPS).
//Note: hmax is not supported.

//NOTE: Deprecated in favor of the format array.
//Minimum width in device independent pixels (DIPS).
//Note: wmin is not supported.

//NOTE: Deprecated in favor of the format array.
//Minimum height in device independent pixels (DIPS).
//Note: hmin is not supported.

//Blocked banner ad types. Refer to List 5.2.
//Note: btype is not supported.

//Blocked creative attributes. Refer to List 5.3.
//Note: battr is not supported.

//Ad position on screen. Refer to List 5.4:
//The following table specifies the position of the ad as a relative measure of visibility or prominence. This
//OpenRTB table has values derived from the Inventory Quality Guidelines (IQG). Practitioners should
//keep in sync with updates to the IQG values as published on IAB.com. Values “4” - “7” apply to apps per
//the mobile addendum to IQG version 2.1.
//Value Description
//0 Unknown
//1 Above the Fold
//2 DEPRECATED - May or may not be initially visible depending on screen size/resolution.
//3 Below the Fold
//4 Header
//5 Footer
//6 Sidebar
//7 Full Screen
@property (nonatomic, strong, nullable) NSNumber *pos;

//Content MIME types supported. Popular MIME types may include “application/x-shockwave-flash”, “image/jpg”, and “image/gif"
//Note: mimes is not supported.

//Integer. Indicates if the banner is in the top frame as opposed to an iframe, where 0 = no, 1 = yes
//Note: topframe is not supported.

//Directions in which the banner may expand. See table 5.5:
//5.5 Expandable Direction
//The following table lists the directions in which an expandable ad may expand, given the positioning of
//the ad unit on the page and constraints imposed by the content.
//Value Description
//1 Left
//2 Right
//3 Up
//4 Down
//5 Full Screen
//Note: expdir is not supported.

//List of supported API frameworks for this impression. If an API is not explicitly listed, it is assumed not to be supported
//1) VPAID 1.0
//2) VPAID 2.0
//3) MRAID-1
//4) ORMMA
//5) MRAID-2
//6) MRAID-3
//Note: SDK supports MRAID 1, MRAID 2 MRAID 3, OMID 1
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *api;

//Unique identifier for this banner object. Recommended when Banner objects are used with a Video object to represent an array of companion ads. Values usually start at 1 and increase with each object; should be unique within an impression
//Note: id is not supported.

//Relevant only for Banner objects used with a Video object
//(Section 3.2.7) in an array of companion ads. Indicates the
//companion banner rendering mode relative to the associated
//video, where 0 = concurrent, 1 = end-card.
//Note: vcm is not supported.

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext is not supported.

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
