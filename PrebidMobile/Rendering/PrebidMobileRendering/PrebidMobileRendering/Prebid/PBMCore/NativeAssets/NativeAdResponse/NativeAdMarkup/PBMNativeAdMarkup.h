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

#import "PBMNativeAdMarkupAsset.h"
#import "PBMNativeAdMarkupEventTracker.h"
#import "PBMNativeAdMarkupLink.h"

#import "PBMJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkup : NSObject <PBMJsonStringDecodable>

/// Version of the Native Markup version in use.
@property (nonatomic, copy, nullable) NSString *version;

/// List of native ad’s assets.
/// Required if no assetsurl.
/// Recommended as fallback even if assetsurl is provided.
@property (nonatomic, strong, nullable) NSArray<PBMNativeAdMarkupAsset *> *assets;

/// URL of an alternate source for the assets object.
/// The expected response is a JSON object mirroring the assets object in the bid response,
/// subject to certain requirements as specified in the individual objects.
/// Where present, overrides the asset object in the response.
@property (nonatomic, copy, nullable) NSString *assetsurl;

/// URL where a dynamic creative specification may be found for populating this ad, per the Dynamic Content Ads Specification.
/// Note this is a beta option as the interpretation of the Dynamic Content Ads Specification and how to assign those elements
/// into a native ad is outside the scope of this spec and must be agreed offline between the parties
/// or as may be specified in a future revision of the Dynamic Content Ads spec.
/// Where present, overrides the asset object in the response.
@property (nonatomic, copy, nullable) NSString *dcourl;

/// Destination Link.
/// This is default link object for the ad.
/// Individual assets can also have a link object which applies if the asset is activated(clicked).
/// If the asset doesn’t have a link object, the parent link object applies.
/// See LinkObject Definition
@property (nonatomic, strong, nullable) PBMNativeAdMarkupLink *link;

/// Array of impression tracking URLs, expected to return a 1x1 image or 204 response - typically only passed when using 3rd party trackers.
/// To be deprecated - replaced with eventtrackers.
@property (nonatomic, copy, nullable) NSArray<NSString *> *imptrackers;

/// Optional JavaScript impression tracker.
/// This is a valid HTML, Javascript is already wrapped in <script> tags.
/// It should be executed at impression time where it can be supported.
/// To be deprecated - replaced with eventtrackers.
@property (nonatomic, copy, nullable) NSString *jstracker;

/// Array of tracking objects to run with the ad, in response to the declared supported methods in the request.
/// Replaces imptrackers and jstracker, to be deprecated.
@property (nonatomic, strong, nullable) NSArray<PBMNativeAdMarkupEventTracker *> *eventtrackers;

/// If support was indicated in the request, URL of a page informing the user about the buyer’s targeting activity.
@property (nonatomic, copy, nullable) NSString *privacy;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithLink:(PBMNativeAdMarkupLink *)link;

@end

NS_ASSUME_NONNULL_END
