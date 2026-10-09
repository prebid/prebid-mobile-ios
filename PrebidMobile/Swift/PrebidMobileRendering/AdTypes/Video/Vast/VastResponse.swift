//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// This class is analogous to the <VAST> tag at the root of a Vast XML doc.
@objc(PBMVastResponse)
@_spi(PBMInternal) public class VastResponse: NSObject {

    // TODO: Refactor VastResponse.nextResponse and VastWrapperAd.vastResponse together.

    @objc public var nextResponse: VastResponse?
    @objc public weak var parentResponse: VastResponse?
    @objc public var noAdsResponseURI: String?
    // Untyped `NSMutableArray`: elements are `VastAbstractAd`; ObjC code assigns mutable arrays here.
    // TODO: should be readonly
    @objc public var vastAbstractAds = NSMutableArray()
    @objc public var version: String?

    @objc public override init() {
        super.init()
    }

    // TODO: Check support for adPods

    // Flatten response compacts all the chaining <Wrapper> tags in a Vast response.

    // <Wrapper> tags can chain but ultimately terminate in an <InLine> tag.
    // <Wrapper> tags may have an optional <Creative> tag. If the creative is of type <Linear> or <NonLinear>, then we are to
    // take the tracking information and add it to the terminating <InLine> tag's creative.
    // If it's of type Companion, then we are to keep the companion in a separate data structure (something we don't currently support)

    @objc(flattenResponseAndReturnError:)
    public func flattenResponse() throws -> [VastAbstractAd] {
        var inlineAdAccumulator = [VastAbstractAd]()

        for ad in vastAbstractAds {
            if let inlineAd = ad as? VastInlineAd {
                inlineAdAccumulator.append(inlineAd)
            } else if let wrapper = ad as? VastWrapperAd {
                // If this is a wrapper then we should have a nextResponse child
                guard let unwrappedVastResponse = wrapper.vastResponse else {
                    throw Self.error(message: "No nextResponse on a wrapper", type: PBMErrorType.serverError)
                }

                // Start by "flattening" it such that any Wrappers Ads in its ads array are resolved into Inline Ads.
                let inlineAdsFromWrapper = try unwrappedVastResponse.flattenResponse()

                // Copy our tracking info onto the inline ads
                unwrappedVastResponse.copyTracking(fromWrapper: wrapper, toInlineAds: inlineAdsFromWrapper)
                inlineAdAccumulator.append(contentsOf: inlineAdsFromWrapper)
            } else {
                throw Self.error(message: "Encountered unexpected class type: \(ad)", type: PBMErrorType.internalError)
            }
        }

        // Post-flattening, we should have at least 1 ad
        if inlineAdAccumulator.isEmpty {
            throw Self.error(message: "No Inline Ads found during wrapper flattening", type: PBMErrorType.internalError)
        }

        return inlineAdAccumulator
    }

    // MARK: - Private

    // Matches `+[PBMError createError:message:type:]`, which logged the error it created.
    private static func error(message: String, type: PBMErrorType) -> PBMError {
        let error = PBMError.error(message: message, type: type)
        Log.error("\(error)")
        return error
    }

    private func copyTracking(fromWrapper wrapper: VastWrapperAd, toInlineAds inlineAds: [VastAbstractAd]) {

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // We assume that Creatives on Wrapper elements are essentially "fake" and only contain additional tracking
        // information for ads in the child response.
        // We also assume that they can occasionally contain the companion ad creative for ads in the child response,
        // but we don't support that feature.
        //
        // This seems to be a safe assumption of industry practices based on some googling of criticism of the VAST spec:
        // https://www.aerserv.com/vast-wrapper-problems/
        //
        // And IAB's own statements on how Wrapper creatives work:
        // https://www.iab.com/wp-content/uploads/2015/06/VASTv3_0.pdf
        // Which reads:
        //
        //  Since a Wrapper redirects the video player to another server for the Ad, including creative in the
        //  Wrapper is optional. In some cases, the Companion creative for an Ad may be included with resource
        //  files in the Wrapper, while redirecting the video player to another server for the Inline Linear or
        //  NonLinear portion of the Ad.
        //
        //  Creative elements in a Wrapper are typically used to collect tracking information on the InLine creative
        //  that are served subsequent to the Wrapper. If the <Creatives> element is included in the Wrapper,
        //  one or more <Creative> elements may be included (but is not required; an empty <Creatives>
        //  element is acceptable). At most, each <Creative> element may contain one of: <Linear>,
        //  <NonLinearAds>, or <CompanionAds>.
        //
        //  Wrapper creative differ from InLine creative. The following sections describe each in detail.
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////

        // Copy tracking info from this wrapper onto its inline ads.
        for case let inlineAd as VastInlineAd in inlineAds {

            // Walk the creatives on the wrapper
            for case let wrapperCreative as VastCreativeAbstract in wrapper.creatives {

                // If the inline ad has any "real" creatives of the same type as the "fake" creatives on the wrapper,
                // copy the "fake" creative's tracking info onto the "real" creative.
                for case let inlineAdCreative as VastCreativeAbstract in inlineAd.creatives {

                    if let inlineLinear = inlineAdCreative as? VastCreativeLinear,
                       let wrapperLinear = wrapperCreative as? VastCreativeLinear {
                        inlineLinear.clickTrackingURIs.addObjects(from: Array(wrapperLinear.clickTrackingURIs))
                        inlineLinear.vastTrackingEvents.addTrackingEvents(wrapperLinear.vastTrackingEvents)
                    } else if let inlineNonLinearAds = inlineAdCreative as? VastCreativeNonLinearAds,
                              let wrapperNonLinearAds = wrapperCreative as? VastCreativeNonLinearAds {
                        inlineNonLinearAds.copyTracking(fromNonLinearAds: wrapperNonLinearAds)
                    } else if let inlineCompanionAds = inlineAdCreative as? VastCreativeCompanionAds,
                              let wrapperCompanionAds = wrapperCreative as? VastCreativeCompanionAds {
                        inlineCompanionAds.copyTracking(fromCompanionAds: wrapperCompanionAds)
                    }
                }
            }

            inlineAd.impressionURIs.addObjects(from: Array(wrapper.impressionURIs))
            inlineAd.errorURIs.addObjects(from: Array(wrapper.errorURIs))
        }
    }
}
