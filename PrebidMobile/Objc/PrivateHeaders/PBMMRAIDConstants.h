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

#import <Foundation/Foundation.h>

//MARK: MRAID Actions
typedef NSString * _Nonnull PBMMRAIDAction NS_TYPED_ENUM;
// Debug
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionLog;
// MRAID 1
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionOpen;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionClose;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionExpand;
// MRAID 2
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionResize;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionStorePicture;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionCreateCalendarEvent;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionPlayVideo;
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionOnOrientationPropertiesChanged;
// MRAID 3
FOUNDATION_EXPORT PBMMRAIDAction const PBMMRAIDActionUnload;
// ---- end MRAID Actions

// mraid enums and structs
typedef NSString * _Nonnull PBMMRAIDPlacementType NS_TYPED_ENUM;
FOUNDATION_EXPORT PBMMRAIDPlacementType const PBMMRAIDPlacementTypeInline;
FOUNDATION_EXPORT PBMMRAIDPlacementType const PBMMRAIDPlacementTypeInterstitial;

typedef NSString * _Nonnull PBMMRAIDFeature NS_TYPED_ENUM;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureSMS;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeaturePhone;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureCalendar;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureSavePicture;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureInlineVideo;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureLocation;
FOUNDATION_EXPORT PBMMRAIDFeature const PBMMRAIDFeatureVPAID;

// Class interfaces moved to MRAIDConstants.swift (available via PrebidMobile-Swift.h).
// Import SwiftImport.h to use PBMMRAIDParseKeys, PBMMRAIDValues,
// PBMMRAIDCloseButtonPosition, PBMMRAIDCloseButtonSize,
// PBMMRAIDExpandProperties (NS_SWIFT_NAME MRAIDExpandProperties),
// PBMMRAIDResizeProperties (NS_SWIFT_NAME MRAIDResizeProperties),
// and PBMMRAIDConstants.
