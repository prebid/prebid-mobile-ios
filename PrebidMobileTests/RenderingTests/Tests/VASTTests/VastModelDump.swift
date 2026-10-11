/*   Copyright 2018-2025 Prebid.org, Inc.

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

@_spi(PBMInternal) @testable import PrebidMobile

/// Renders a parsed VAST model as deterministic text, so a parser's output can be compared against a literal
/// expectation. Every property the parser writes is printed; `nil` and `""` are distinguished.
enum VastModelDump {

    static func dump(_ response: VastResponse?) -> String {
        guard let response else {
            return "PARSE FAILED (nil response)\n"
        }

        var lines = [String]()
        lines.append("response.version=\(quoted(response.version))")
        lines.append("response.noAdsResponseURI=\(quoted(response.noAdsResponseURI))")
        lines.append("response.nextResponse=\(response.nextResponse == nil ? "nil" : "set")")
        lines.append("response.parentResponse=\(response.parentResponse == nil ? "nil" : "set")")
        lines.append("response.ads.count=\(response.vastAbstractAds.count)")

        for (adIndex, element) in response.vastAbstractAds.enumerated() {
            let prefix = "ad[\(adIndex)]"
            guard let ad = element as? VastAbstractAd else {
                lines.append("\(prefix)=NOT A VastAbstractAd")
                continue
            }

            lines.append("\(prefix).kind=\(kind(of: ad))")
            lines.append("\(prefix).ownerResponse=\(ad.ownerResponse === response ? "response" : "other")")
            lines.append("\(prefix).identifier=\(quoted(ad.identifier))")
            lines.append("\(prefix).sequence=\(ad.sequence)")
            lines.append("\(prefix).adSystem=\(quoted(ad.adSystem))")
            lines.append("\(prefix).adSystemVersion=\(quoted(ad.adSystemVersion))")
            lines.append("\(prefix).impressionURIs=\(list(ad.impressionURIs))")
            lines.append("\(prefix).errorURIs=\(list(ad.errorURIs))")

            if let inlineAd = ad as? VastInlineAd {
                lines.append("\(prefix).title=\(quoted(inlineAd.title))")
                lines.append("\(prefix).advertiser=\(quoted(inlineAd.advertiser))")
                lines.append("\(prefix).verification.autoPlay=\(inlineAd.verificationParameters.autoPlay)")
                lines.append("\(prefix).verification.count=\(inlineAd.verificationParameters.verificationResources.count)")
                for (resourceIndex, resource) in inlineAd.verificationParameters.verificationResources.enumerated() {
                    let resourcePrefix = "\(prefix).verification[\(resourceIndex)]"
                    lines.append("\(resourcePrefix).vendorKey=\(quoted(resource.vendorKey))")
                    lines.append("\(resourcePrefix).url=\(quoted(resource.url))")
                    lines.append("\(resourcePrefix).params=\(quoted(resource.params))")
                    lines.append("\(resourcePrefix).apiFramework=\(quoted(resource.apiFramework))")
                    if let trackingEvents = resource.trackingEvents {
                        lines.append(contentsOf: trackingLines(trackingEvents, prefix: "\(resourcePrefix).trackingEvents"))
                    } else {
                        lines.append("\(resourcePrefix).trackingEvents=nil")
                    }
                }
            }

            if let wrapperAd = ad as? VastWrapperAd {
                lines.append("\(prefix).vastURI=\(quoted(wrapperAd.vastURI))")
                lines.append("\(prefix).vastResponse=\(wrapperAd.vastResponse == nil ? "nil" : "set")")
                lines.append("\(prefix).depth=\(wrapperAd.depth)")
                lines.append("\(prefix).followAdditionalWrappers=\(wrapperAd.followAdditionalWrappers)")
                lines.append("\(prefix).allowMultipleAds=\(wrapperAd.allowMultipleAds)")
                lines.append("\(prefix).fallbackOnNoAd=\(wrapperAd.fallbackOnNoAd)")
            }

            lines.append("\(prefix).creatives.count=\(ad.creatives.count)")
            for (creativeIndex, creativeElement) in ad.creatives.enumerated() {
                lines.append(contentsOf: creativeLines(creativeElement, prefix: "\(prefix).creative[\(creativeIndex)]"))
            }
        }

        return lines.joined(separator: "\n") + "\n"
    }

    // MARK: - Creatives

    private static func creativeLines(_ element: Any, prefix: String) -> [String] {
        guard let creative = element as? VastCreativeAbstract else {
            return ["\(prefix)=NOT A VastCreativeAbstract"]
        }

        var lines = [String]()
        lines.append("\(prefix).kind=\(kind(of: creative))")
        lines.append("\(prefix).id=\(quoted(creative.id))")
        lines.append("\(prefix).adId=\(quoted(creative.adId))")
        lines.append("\(prefix).sequence=\(creative.sequence)")
        lines.append("\(prefix).adParameters=\(quoted(creative.adParameters))")

        if let linear = creative as? VastCreativeLinear {
            lines.append(contentsOf: linearLines(linear, prefix: prefix))
        }

        if let companionAds = creative as? VastCreativeCompanionAds {
            lines.append(contentsOf: companionLines(companionAds, prefix: prefix))
        }

        if let nonLinearAds = creative as? VastCreativeNonLinearAds {
            lines.append(contentsOf: nonLinearLines(nonLinearAds, prefix: prefix))
        }

        return lines
    }

    private static func linearLines(_ linear: VastCreativeLinear, prefix: String) -> [String] {
        var lines = [String]()
        lines.append("\(prefix).skipOffset=\(number(linear.skipOffset))")
        lines.append("\(prefix).duration=\(linear.duration)")
        lines.append("\(prefix).clickThroughURI=\(quoted(linear.clickThroughURI))")
        lines.append("\(prefix).clickTrackingURIs=\(list(linear.clickTrackingURIs))")
        lines.append(contentsOf: trackingLines(linear.vastTrackingEvents, prefix: "\(prefix).trackingEvents"))
        lines.append("\(prefix).mediaFiles.count=\(linear.mediaFiles.count)")
        for (index, mediaFileElement) in linear.mediaFiles.enumerated() {
            guard let mediaFile = mediaFileElement as? VastMediaFile else {
                lines.append("\(prefix).mediaFile[\(index)]=NOT A VastMediaFile")
                continue
            }
            let mediaPrefix = "\(prefix).mediaFile[\(index)]"
            lines.append("\(mediaPrefix).id=\(quoted(mediaFile.id))")
            lines.append("\(mediaPrefix).streamingDeliver=\(mediaFile.streamingDeliver)")
            lines.append("\(mediaPrefix).type=\(quoted(mediaFile.type))")
            lines.append("\(mediaPrefix).width=\(mediaFile.width)")
            lines.append("\(mediaPrefix).height=\(mediaFile.height)")
            lines.append("\(mediaPrefix).codec=\(quoted(mediaFile.codec))")
            lines.append("\(mediaPrefix).apiFramework=\(quoted(mediaFile.apiFramework))")
            lines.append("\(mediaPrefix).bitrate=\(number(mediaFile.bitrate))")
            lines.append("\(mediaPrefix).minBitrate=\(number(mediaFile.minBitrate))")
            lines.append("\(mediaPrefix).maxBitrate=\(number(mediaFile.maxBitrate))")
            lines.append("\(mediaPrefix).scalable=\(number(mediaFile.scalable))")
            lines.append("\(mediaPrefix).maintainAspectRatio=\(number(mediaFile.maintainAspectRatio))")
            lines.append("\(mediaPrefix).mediaURI=\(quoted(mediaFile.mediaURI))")
        }
        lines.append("\(prefix).icons.count=\(linear.icons.count)")
        for (index, iconElement) in linear.icons.enumerated() {
            guard let icon = iconElement as? VastIcon else {
                lines.append("\(prefix).icon[\(index)]=NOT A VastIcon")
                continue
            }
            let iconPrefix = "\(prefix).icon[\(index)]"
            lines.append("\(iconPrefix).program=\(quoted(icon.program))")
            lines.append("\(iconPrefix).width=\(icon.width)")
            lines.append("\(iconPrefix).height=\(icon.height)")
            lines.append("\(iconPrefix).xPosition=\(icon.xPosition)")
            lines.append("\(iconPrefix).yPosition=\(icon.yPosition)")
            lines.append("\(iconPrefix).duration=\(icon.duration)")
            lines.append("\(iconPrefix).startOffset=\(icon.startOffset)")
            lines.append("\(iconPrefix).clickThroughURI=\(quoted(icon.clickThroughURI))")
            lines.append("\(iconPrefix).clickTrackingURIs=\(list(icon.clickTrackingURIs))")
            lines.append("\(iconPrefix).viewTrackingURI=\(quoted(icon.viewTrackingURI))")
            lines.append("\(iconPrefix).resourceType=\(icon.resourceType.rawValue)")
            lines.append("\(iconPrefix).resource=\(quoted(icon.resource))")
            lines.append("\(iconPrefix).staticType=\(quoted(icon.staticType))")
        }
        return lines
    }

    private static func companionLines(_ companionAds: VastCreativeCompanionAds, prefix: String) -> [String] {
        var lines = [String]()
        lines.append("\(prefix).requiredMode=\(quoted(companionAds.requiredMode))")
        lines.append("\(prefix).companions.count=\(companionAds.companions.count)")
        for (index, companionElement) in companionAds.companions.enumerated() {
            guard let companion = companionElement as? VastCreativeCompanionAdsCompanion else {
                lines.append("\(prefix).companion[\(index)]=NOT A Companion")
                continue
            }
            let companionPrefix = "\(prefix).companion[\(index)]"
            lines.append("\(companionPrefix).companionIdentifier=\(quoted(companion.companionIdentifier))")
            lines.append("\(companionPrefix).width=\(companion.width)")
            lines.append("\(companionPrefix).height=\(companion.height)")
            lines.append("\(companionPrefix).assetWidth=\(companion.assetWidth)")
            lines.append("\(companionPrefix).assetHeight=\(companion.assetHeight)")
            lines.append("\(companionPrefix).adParameters=\(quoted(companion.adParameters))")
            lines.append("\(companionPrefix).clickThroughURI=\(quoted(companion.clickThroughURI))")
            lines.append("\(companionPrefix).clickTrackingURIs=\(list(companion.clickTrackingURIs))")
            lines.append("\(companionPrefix).resourceType=\(companion.resourceType.rawValue)")
            lines.append("\(companionPrefix).resource=\(quoted(companion.resource))")
            lines.append("\(companionPrefix).staticType=\(quoted(companion.staticType))")
            lines.append(contentsOf: trackingLines(companion.trackingEvents, prefix: "\(companionPrefix).trackingEvents"))
        }
        return lines
    }

    private static func nonLinearLines(_ nonLinearAds: VastCreativeNonLinearAds, prefix: String) -> [String] {
        var lines = [String]()
        lines.append("\(prefix).resourceType=\(nonLinearAds.resourceType.rawValue)")
        lines.append("\(prefix).resource=\(quoted(nonLinearAds.resource))")
        lines.append("\(prefix).staticType=\(quoted(nonLinearAds.staticType))")
        lines.append("\(prefix).nonLinears.count=\(nonLinearAds.nonLinears.count)")
        for (index, nonLinearElement) in nonLinearAds.nonLinears.enumerated() {
            guard let nonLinear = nonLinearElement as? VastCreativeNonLinearAdsNonLinear else {
                lines.append("\(prefix).nonLinear[\(index)]=NOT A NonLinear")
                continue
            }
            let nonLinearPrefix = "\(prefix).nonLinear[\(index)]"
            lines.append("\(nonLinearPrefix).id=\(quoted(nonLinear.id))")
            lines.append("\(nonLinearPrefix).width=\(nonLinear.width)")
            lines.append("\(nonLinearPrefix).height=\(nonLinear.height)")
            lines.append("\(nonLinearPrefix).assetWidth=\(nonLinear.assetWidth)")
            lines.append("\(nonLinearPrefix).assetHeight=\(nonLinear.assetHeight)")
            lines.append("\(nonLinearPrefix).scalable=\(nonLinear.scalable)")
            lines.append("\(nonLinearPrefix).maintainAspectRatio=\(nonLinear.maintainAspectRatio)")
            lines.append("\(nonLinearPrefix).minSuggestedDuration=\(nonLinear.minSuggestedDuration)")
            lines.append("\(nonLinearPrefix).apiFramework=\(quoted(nonLinear.apiFramework))")
            lines.append("\(nonLinearPrefix).clickThroughURI=\(quoted(nonLinear.clickThroughURI))")
            lines.append("\(nonLinearPrefix).clickTrackingURIs=\(list(nonLinear.clickTrackingURIs))")
            lines.append("\(nonLinearPrefix).resourceType=\(nonLinear.resourceType.rawValue)")
            lines.append("\(nonLinearPrefix).resource=\(quoted(nonLinear.resource))")
            lines.append("\(nonLinearPrefix).staticType=\(quoted(nonLinear.staticType))")
            lines.append(contentsOf: trackingLines(nonLinear.vastTrackingEvents, prefix: "\(nonLinearPrefix).trackingEvents"))
        }
        return lines
    }

    // MARK: - Helpers

    private static func kind(of object: NSObject) -> String {
        switch object {
        case is VastInlineAd: return "InlineAd"
        case is VastWrapperAd: return "WrapperAd"
        case is VastCreativeLinear: return "Linear"
        case is VastCreativeCompanionAds: return "CompanionAds"
        case is VastCreativeNonLinearAds: return "NonLinearAds"
        case is VastCreativeAbstract: return "CreativeAbstract"
        default: return "VastAbstractAd"
        }
    }

    private static func trackingLines(_ trackingEvents: VastTrackingEvents, prefix: String) -> [String] {
        var lines = [String]()
        for event in trackingEvents.trackingEvents.keys.sorted() {
            let urls = (trackingEvents.trackingEvents[event] ?? []).map { quoted($0) }
            lines.append("\(prefix).\(event)=\(urls.joined(separator: ","))")
        }
        lines.append("\(prefix).progressOffsets=\(trackingEvents.progressOffsets.map { "\($0)" }.joined(separator: ","))")
        return lines
    }

    private static func quoted(_ value: String?) -> String {
        guard let value else {
            return "nil"
        }
        return String(reflecting: value)
    }

    private static func number(_ value: NSNumber?) -> String {
        guard let value else {
            return "nil"
        }
        return "\(value)"
    }

    private static func list(_ array: NSMutableArray) -> String {
        let items = array.map { element in
            (element as? String).map { quoted($0) } ?? "NOT A STRING: \(element)"
        }
        return "[" + items.joined(separator: ", ") + "]"
    }
}
