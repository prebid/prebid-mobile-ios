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

NS_ASSUME_NONNULL_BEGIN

//https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md

@interface PBMORTBBidExtSkadnSKOverlay : PBMORTBAbstract

// Delay before presenting SKOverlay in seconds, required for overlay to be shown
@property (nonatomic, copy, nullable) NSNumber *delay;
// Delay before presenting SKOverlay on an endcard in seconds, required for overlay to be shown
@property (nonatomic, copy, nullable) NSNumber *endcarddelay;
// Whether overlay can be dismissed by user, 0 = no, 1 = yes
@property (nonatomic, copy, nullable) NSNumber *dismissable;
// Position of the overlay, 0 = bottom, 1 = bottom raised
@property (nonatomic, copy, nullable) NSNumber *pos;
// Placeholder for exchange-specific extensions to OpenRTB
@property (nonatomic, copy, nullable) NSString *ext;

@end


NS_ASSUME_NONNULL_END

