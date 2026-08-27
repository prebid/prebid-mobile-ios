/*   Copyright 2018-2021 Prebid.org, Inc.

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

// NS_TYPED_ENUM constant definitions — class implementations moved to MRAIDConstants.swift

#import "PBMMRAIDConstants.h"

//MARK: MRAID Actions
PBMMRAIDAction const PBMMRAIDActionLog                          = @"log";
PBMMRAIDAction const PBMMRAIDActionOpen                         = @"open";
PBMMRAIDAction const PBMMRAIDActionClose                        = @"close";
PBMMRAIDAction const PBMMRAIDActionExpand                       = @"expand";
PBMMRAIDAction const PBMMRAIDActionResize                       = @"resize";
PBMMRAIDAction const PBMMRAIDActionStorePicture                 = @"storepicture";
PBMMRAIDAction const PBMMRAIDActionCreateCalendarEvent          = @"createCalendarevent";
PBMMRAIDAction const PBMMRAIDActionPlayVideo                    = @"playVideo";
PBMMRAIDAction const PBMMRAIDActionOnOrientationPropertiesChanged = @"onOrientationPropertiesChanged";
PBMMRAIDAction const PBMMRAIDActionUnload                       = @"unload";

PBMMRAIDPlacementType const PBMMRAIDPlacementTypeInline         = @"inline";
PBMMRAIDPlacementType const PBMMRAIDPlacementTypeInterstitial   = @"interstitial";

PBMMRAIDFeature const PBMMRAIDFeatureSMS                        = @"sms";
PBMMRAIDFeature const PBMMRAIDFeaturePhone                      = @"tel";
PBMMRAIDFeature const PBMMRAIDFeatureCalendar                   = @"calendar";
PBMMRAIDFeature const PBMMRAIDFeatureSavePicture                = @"storePicture";
PBMMRAIDFeature const PBMMRAIDFeatureInlineVideo                = @"inlineVideo";
PBMMRAIDFeature const PBMMRAIDFeatureLocation                   = @"location";
PBMMRAIDFeature const PBMMRAIDFeatureVPAID                      = @"vpaid";
