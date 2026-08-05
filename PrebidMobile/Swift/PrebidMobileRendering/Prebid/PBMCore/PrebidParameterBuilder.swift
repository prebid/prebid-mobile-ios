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

import Foundation
import UIKit

@objc(PBMPrebidParameterBuilder) @_spi(PBMInternal) public
class PrebidParameterBuilder: NSObject, ParameterBuilder {

    private let adConfiguration: AdUnitConfig
    private let sdkConfiguration: Prebid
    private let targeting: Targeting
    private let userAgentService: UserAgentService

    @objc public init(
        adConfiguration: AdUnitConfig,
        sdkConfiguration: Prebid,
        targeting: Targeting,
        userAgentService: UserAgentService
    ) {
        self.adConfiguration = adConfiguration
        self.sdkConfiguration = sdkConfiguration
        self.targeting = targeting
        self.userAgentService = userAgentService
        super.init()
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func build(_ bidRequest: ORTBBidRequest) {
        let adFormats = adConfiguration.adConfiguration.adFormats
        let isHTML = adFormats.contains(.banner)
        let isInterstitial = adConfiguration.adConfiguration.isInterstitialAd

        var requestID = sdkConfiguration.prebidServerAccountId
        if let settingsID = sdkConfiguration.auctionSettingsId {
            if settingsID.trimmingCharacters(in: .whitespaces).isEmpty {
                Log.warn("Auction settings Id is invalid. Prebid Server Account Id will be used.")
            } else {
                requestID = settingsID
            }
        }

        bidRequest.requestID = UUID().uuidString
        bidRequest.extPrebid.storedRequestID = requestID
        bidRequest.extPrebid.storedAuctionResponse = Prebid.shared.storedAuctionResponse
        bidRequest.extPrebid.dataBidders = targeting.accessControlList
        bidRequest.extPrebid.storedBidResponses = Prebid.shared.getStoredBidResponses()

        if !adConfiguration.adConfiguration.isOriginalAPI {
            bidRequest.extPrebid.sdkRenderers = PrebidMobilePluginRegister.shared.getAllPluginsJSONRepresentation()
        }

        if Prebid.shared.pbsDebug {
            bidRequest.test = 1
        }

        // Note: filterOutUncachedBids is intentionally not checked here. It only controls
        // whether uncached bids are filtered out of the response for Original API; it never
        // requests caching on its own. Original API already asks PBS to cache bids via
        // useCacheForReportingWithRenderingAPI (see AdUnit.init), so cache is always requested
        // wherever filterOutUncachedBids could apply.
        if Prebid.shared.useCacheForReportingWithRenderingAPI {
            let cache = NSMutableDictionary()
            cache["bids"] = NSMutableDictionary()
            cache["vastxml"] = NSMutableDictionary()
            bidRequest.extPrebid.cache = cache
        }

        // For multiformat ad units we should get hb_format in PBS response.
        // In order to do this, we should specify ext.prebid.targeting.includeformat
        if adFormats.count >= 2 {
            bidRequest.extPrebid.targeting["includeformat"] = NSNumber(value: true)
        }

        if Prebid.shared.includeWinners {
            bidRequest.extPrebid.targeting["includewinners"] = NSNumber(value: true)
        }

        if Prebid.shared.includeBidderKeys {
            bidRequest.extPrebid.targeting["includebidderkeys"] = NSNumber(value: true)
        }

        bidRequest.app.publisher?.publisherID = sdkConfiguration.prebidServerAccountId
        bidRequest.app.ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        bidRequest.device.pxratio = NSNumber(value: Double(UIScreen.main.scale))
        bidRequest.source.tid = UUID().uuidString
        bidRequest.device.ua = userAgentService.userAgent

        if let gdprConsentString = targeting.gdprConsentString, !gdprConsentString.isEmpty {
            bidRequest.user.ext?["consent"] = gdprConsentString
        }

        let extSource = ORTBSourceExtOMID()

        if !adConfiguration.adConfiguration.isOriginalAPI {
            extSource.omidpn = "Prebid"
            extSource.omidpv = Functions.sdkVersion
        }

        if let omidPartnerName = Targeting.shared.omidPartnerName {
            extSource.omidpn = omidPartnerName
        }

        if let omidPartnerVersion = Targeting.shared.omidPartnerVersion {
            extSource.omidpv = omidPartnerVersion
        }

        bidRequest.source.extOMID = extSource

        var formats: [ORTBFormat]?
        let formatsCount = (adConfiguration.adSize == .zero ? 0 : 1) + (adConfiguration.additionalSizes?.count ?? 0)

        if formatsCount > 0 {
            var newFormats: [ORTBFormat] = []
            newFormats.reserveCapacity(formatsCount)
            if adConfiguration.adSize != .zero {
                newFormats.append(Self.ortbFormat(withSize: adConfiguration.adSize))
            }
            for nextSize in adConfiguration.additionalSizes ?? [] {
                newFormats.append(Self.ortbFormat(withSize: nextSize))
            }
            formats = newFormats
        } else if isInterstitial {
            if let minSizePerc = adConfiguration.minSizePerc, isHTML {
                let minSizePercValue = minSizePerc.cgSizeValue
                let interstitial = bidRequest.device.extPrebid.interstitial
                interstitial.minwidthperc = NSNumber(value: Double(minSizePercValue.width))
                interstitial.minheightperc = NSNumber(value: Double(minSizePercValue.height))
            }
        }

        let appExt = bidRequest.app.ext
        let appExtPrebid = appExt.prebid

        let appExtData = targeting.getAppExtData()
        if !appExtData.isEmpty {
            appExt.data = appExtData
        }

        for nextImp in bidRequest.imp {
            nextImp.impID = UUID().uuidString
            nextImp.extPrebid.storedRequestID = adConfiguration.configId
            nextImp.extPrebid.storedAuctionResponse = Prebid.shared.storedAuctionResponse
            nextImp.extGPID = adConfiguration.gpid

            nextImp.extPrebid.isRewardedInventory = adConfiguration.adConfiguration.isRewarded
            if adConfiguration.adConfiguration.isRewarded {
                nextImp.rewarded = 1
            }

            let pbAdSlot = adConfiguration.getPbAdSlot()
            nextImp.extData?["pbadslot"] = pbAdSlot

            for adFormat in adFormats {
                if adFormat == .banner, let nextBanner = nextImp.banner {
                    let bannerParameters = adConfiguration.adConfiguration.bannerParameters
                    var mergedFormats: [ORTBFormat] = []

                    if let formats = formats {
                        mergedFormats.append(contentsOf: formats)
                    }

                    if let adSizes = bannerParameters.adSizes, !adSizes.isEmpty {
                        for sizeValue in adSizes {
                            mergedFormats.append(Self.ortbFormat(withSize: sizeValue))
                        }
                    }

                    let uniqueFormats = NSSet(array: mergedFormats).allObjects.compactMap { $0 as? ORTBFormat }
                    if !uniqueFormats.isEmpty {
                        nextBanner.format = uniqueFormats
                    }

                    if bannerParameters.api?.isEmpty == false {
                        nextBanner.api = bannerParameters.rawAPI?.map { NSNumber(value: $0) }
                    }

                    if adConfiguration.adPosition != .undefined {
                        nextBanner.pos = NSNumber(value: adConfiguration.adPosition.rawValue)
                    }
                } else if adFormat == .video, let nextVideo = nextImp.video {
                    if !adConfiguration.adConfiguration.isOriginalAPI {
                        if adConfiguration.adConfiguration.isInterstitialAd {
                            nextVideo.playbackend = 1
                        } else {
                            nextVideo.playbackend = 2
                        }
                        nextVideo.pos = 7
                        nextVideo.protocols = [2, 5]
                        nextVideo.mimes = PrebidConstants.SUPPORTED_VIDEO_MIME_TYPES
                    }

                    nextVideo.delivery = [3]

                    if let formats = formats, !formats.isEmpty {
                        let primarySize = formats[0]
                        nextVideo.w = primarySize.w
                        nextVideo.h = primarySize.h
                    }

                    let videoParameters = adConfiguration.adConfiguration.videoParameters

                    if videoParameters.api?.isEmpty == false {
                        nextVideo.api = videoParameters.rawAPI?.map { NSNumber(value: $0) }
                    }

                    if let maxBitrate = videoParameters.maxBitrate {
                        nextVideo.maxbitrate = NSNumber(value: maxBitrate.value)
                    }

                    if let minBitrate = videoParameters.minBitrate {
                        nextVideo.minbitrate = NSNumber(value: minBitrate.value)
                    }

                    if let maxDuration = videoParameters.maxDuration {
                        nextVideo.maxduration = NSNumber(value: maxDuration.value)
                    }

                    if let minDuration = videoParameters.minDuration {
                        nextVideo.minduration = NSNumber(value: minDuration.value)
                    }

                    if !videoParameters.mimes.isEmpty {
                        nextVideo.mimes = videoParameters.mimes
                    }

                    if videoParameters.playbackMethod?.isEmpty == false {
                        nextVideo.playbackmethod = videoParameters.rawPlaybackMethod?.map { NSNumber(value: $0) }
                    }

                    if videoParameters.protocols?.isEmpty == false {
                        nextVideo.protocols = videoParameters.rawProtocols?.map { NSNumber(value: $0) }
                    }

                    if let startDelay = videoParameters.startDelay {
                        nextVideo.startdelay = NSNumber(value: startDelay.value)
                    }

                    if let placement = videoParameters.placement {
                        nextVideo.placement = NSNumber(value: placement.value)
                    }

                    if let plcmnt = videoParameters.plcmnt {
                        nextVideo.plcmt = NSNumber(value: plcmnt.value)
                    }

                    if let linearity = videoParameters.linearity {
                        nextVideo.linearity = NSNumber(value: linearity.value)
                    }

                    if videoParameters.battr?.isEmpty == false {
                        nextVideo.battr = videoParameters.rawBattrs?.map { NSNumber(value: $0) }
                    }

                    if let skip = videoParameters.rawSkippable {
                        nextVideo.skip = skip
                    }

                    if adConfiguration.adPosition != .undefined {
                        nextVideo.pos = NSNumber(value: adConfiguration.adPosition.rawValue)
                    }
                } else if adFormat == .native, let nextNative = nextImp.native {
                    nextNative.request = try? adConfiguration.nativeAdConfiguration?.markupRequestObject.toJsonString()
                    if let ver = adConfiguration.nativeAdConfiguration?.version {
                        nextNative.ver = ver
                    }
                }
            }

            if isInterstitial {
                nextImp.instl = 1
            }

            if appExtPrebid.source == nil {
                appExtPrebid.source = "prebid-mobile"
            }

            if appExtPrebid.version == nil {
                appExtPrebid.version = Prebid.shared.version
            }
        }
    }

    // MARK: - Private

    private static func ortbFormat(withSize size: CGSize) -> ORTBFormat {
        let format = ORTBFormat()
        format.w = NSNumber(value: Double(size.width))
        format.h = NSNumber(value: Double(size.height))
        return format
    }
}
