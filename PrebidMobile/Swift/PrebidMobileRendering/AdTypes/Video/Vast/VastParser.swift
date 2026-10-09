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

@objc(PBMVastParser)
@_spi(PBMInternal) public class VastParser: NSObject, XMLParserDelegate {

    var parsedResponse: VastResponse?

    var currentElementContext: String?

    var currentElementContent = ""
    var currentElementAttributes: [String: String]?
    var currentElementName = ""
    var elementPath = [String]()

    // Ad
    var ad: VastAbstractAd?
    var inlineAd: VastInlineAd?
    var wrapperAd: VastWrapperAd?
    var adAttributes: [String: String]?

    var verificationParameter: VideoVerificationParameters?
    var verificationResource: VideoVerificationResource?

    // Creative
    var creative: VastCreativeAbstract?
    var creativeAttributes: [String: String]?

    private var parseSuccessful = false

    // MARK: - Initialization

    @objc public override init() {
        super.init()
    }

    @objc(parseAdsResponse:)
    public func parseAdsResponse(_ data: Data) -> VastResponse? {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self

        currentElementContext = ""
        elementPath = [String]()
        xmlParser.parse()

        return parseSuccessful ? parsedResponse : nil
    }

    // The Companion, and NonLinear and Icon tags can all have StaticResource, IFrameResource and
    // HTMLResource tag children. To represent this, the VastIcon,
    // VastCreativeCompanionAdsCompanion, and VastCreativeNonLinearAdsNonLinear classes
    // all conform to VastResourceContainer.
    func parseResource(for type: VastResourceType) {

        guard creative != nil else {
            Log.error("No applicable creative")
            return
        }

        let container = extractCreativeContainer()

        // Bail if unsuccessful
        guard let container else {
            Log.error("No applicable container to apply currentElementContent of [\(currentElementContent)] to. Type is \(type.rawValue).")
            return
        }

        // Fill out VastResourceContainer fields
        container.resourceType = type
        container.resource = currentElementContent
        if type == .staticResource {
            container.staticType = currentElementAttributes?["creativeType"]
        }
    }

    private func parseBool(_ string: String?) -> Bool {
        guard let string else {
            return false
        }
        return string == "true"
    }

    private func parseInt(_ string: String?) -> Int {
        guard let string else {
            return 0
        }
        return (string as NSString).integerValue
    }

    private func parseFloat(_ string: String?) -> Float {
        guard let string else {
            return 0
        }
        return (string as NSString).floatValue
    }

    func parseTimeInterval(_ string: String?) -> TimeInterval {
        guard let string else {
            return 0
        }

        let components = Array(string.components(separatedBy: ":").reversed())
        var totalSeconds: TimeInterval = 0
        var componentIndex = 0

        for component in components {
            let componentValue = (component as NSString).doubleValue
            switch componentIndex {
            case 0: totalSeconds += componentValue // Seconds
            case 1: totalSeconds += componentValue * 60 // Minutes
            case 2: totalSeconds += componentValue * 60 * 60 // Hours

            default:
                Log.error("Unable to parse time string: \(string)")
                return 0
            }

            componentIndex += 1
        }

        return totalSeconds
    }

    private func parseString(_ string: String?) -> String {
        guard let string else {
            return ""
        }
        return string
    }

    private func parseSkipOffset(_ string: String?) -> NSNumber? {
        guard let string else {
            return nil
        }

        let interval = parseTimeInterval(string)
        return NSNumber(value: interval)
    }

    // MARK: - NSXMLParserDelegate

    public func parserDidStartDocument(_ parser: XMLParser) {
        parsedResponse = VastResponse()
    }

    public func parserDidEndDocument(_ parser: XMLParser) {
        // sent when the parser has completed parsing. If this is encountered, the parse was successful.
        parseSuccessful = true
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func parser(_ parser: XMLParser,
                       didStartElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?,
                       attributes attributeDict: [String: String] = [:]) {

        // sent when the parser finds an element start tag.

        elementPath.append(elementName)
        currentElementName = elementName
        currentElementAttributes = attributeDict
        currentElementContent = ""

        switch elementName {
        case "VAST":
            parsedResponse?.version = attributeDict["version"]

        case "Ad":
            adAttributes = attributeDict

        case "InLine":
            let newInlineAd = VastInlineAd()
            inlineAd = newInlineAd
            ad = newInlineAd

        case "Wrapper":
            let newWrapperAd = VastWrapperAd()

            if let followAdditionalWrappersKey = attributeDict["followAdditionalWrappers"] {
                newWrapperAd.followAdditionalWrappers = parseBool(followAdditionalWrappersKey)
            }

            if let allowMultipleAdsKey = attributeDict["allowMultipleAds"] {
                newWrapperAd.allowMultipleAds = parseBool(allowMultipleAdsKey)
            }

            if let fallbackOnNoAdKey = attributeDict["fallbackOnNoAd"] {
                newWrapperAd.fallbackOnNoAd = parseBool(fallbackOnNoAdKey)
            }

            wrapperAd = newWrapperAd
            ad = newWrapperAd

        case "Creative":
            creativeAttributes = attributeDict

        case "Linear":
            let linearCreative = VastCreativeLinear()
            linearCreative.skipOffset = parseSkipOffset(attributeDict["skipoffset"])
            creative = linearCreative

        case "CompanionAds":
            let companionAdsCreative = VastCreativeCompanionAds()
            companionAdsCreative.requiredMode = parseString(attributeDict["required"])
            creative = companionAdsCreative

        case "Companion":
            guard let companionAds = creative as? VastCreativeCompanionAds else {
                Log.error("Error - expected current creative to be PBMVastCreativeCompanionAds")
                return
            }

            let companion = VastCreativeCompanionAdsCompanion()
            companion.companionIdentifier = attributeDict["id"]
            companion.width = parseInt(attributeDict["width"])
            companion.height = parseInt(attributeDict["height"])
            companion.assetWidth = parseInt(attributeDict["assetWidth"])
            companion.assetHeight = parseInt(attributeDict["assetHeight"])
            companionAds.companions.add(companion)

        case "NonLinearAds":
            creative = VastCreativeNonLinearAds()

        case "NonLinear":
            guard let nonLinearAds = creative as? VastCreativeNonLinearAds else {
                Log.error("Expected current creative to be PBMVastCreativeNonLinearAds")
                return
            }

            let nonLinear = VastCreativeNonLinearAdsNonLinear()
            nonLinear.id = attributeDict["id"]
            nonLinear.width = parseInt(attributeDict["width"])
            nonLinear.height = parseInt(attributeDict["height"])
            nonLinear.assetWidth = parseInt(attributeDict["assetWidth"])
            nonLinear.assetHeight = parseInt(attributeDict["assetHeight"])
            nonLinear.scalable = parseBool(attributeDict["scalable"])
            nonLinear.maintainAspectRatio = parseBool(attributeDict["maintainAspectRatio"])
            nonLinear.minSuggestedDuration = parseTimeInterval(attributeDict["minSuggestedDuration"])
            nonLinear.apiFramework = attributeDict["apiFramework"]
            nonLinearAds.nonLinears.add(nonLinear)

        case "Icon":
            guard let linearCreative = creative as? VastCreativeLinear else {
                Log.error("Icon found, but current creative is not PBMVastCreativeLinear")
                return
            }

            let icon = VastIcon()
            icon.program = parseString(attributeDict["program"])
            icon.width = parseInt(attributeDict["width"])
            icon.height = parseInt(attributeDict["height"])
            icon.xPosition = parseInt(attributeDict["xPosition"])
            icon.yPosition = parseInt(attributeDict["yPosition"])
            icon.duration = parseTimeInterval(attributeDict["duration"])
            icon.startOffset = parseTimeInterval(attributeDict["startOffset"])
            linearCreative.icons.add(icon)

        case "MediaFile":
            guard let linearCreative = creative as? VastCreativeLinear else {
                Log.error("MediaFile found, but current creative is not PBMVastCreativeLinear")
                return
            }

            let mediaFile = VastMediaFile()
            mediaFile.id = attributeDict["id"]
            mediaFile.setDeliver(attributeDict["delivery"])
            mediaFile.type = parseString(attributeDict["type"])
            mediaFile.width = parseInt(attributeDict["width"])
            mediaFile.height = parseInt(attributeDict["height"])
            mediaFile.codec = attributeDict["codec"]
            mediaFile.apiFramework = attributeDict["apiFramework"]

            mediaFile.bitrate = NSNumber(value: parseFloat(attributeDict["bitrate"]))
            mediaFile.minBitrate = NSNumber(value: parseFloat(attributeDict["minBitrate"]))
            mediaFile.maxBitrate = NSNumber(value: parseFloat(attributeDict["maxBitrate"]))
            mediaFile.scalable = NSNumber(value: parseBool(attributeDict["scalable"]))
            mediaFile.maintainAspectRatio = NSNumber(value: parseBool(attributeDict["maintainAspectRatio"]))
            linearCreative.mediaFiles.add(mediaFile)

        case "AdVerifications":
            verificationParameter = VideoVerificationParameters()

        case "Verification":
            let resource = VideoVerificationResource()
            resource.vendorKey = attributeDict["vendor"]
            verificationResource = resource

        case "JavaScriptResource":
            verificationResource?.apiFramework = attributeDict["apiFramework"]

        // Unsupported:
        // case "ExecutableResource":
        // case "VerificationParameters":

        default:
            break
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func parser(_ parser: XMLParser,
                       didEndElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?) {
        switch elementName {
        case "Error":
            if Array(elementPath.prefix(2)) == ["VAST", "Ad"] {
                ad?.errorURIs.add(currentElementContent)
            } else if elementPath == ["VAST", "Ad"] {
                parsedResponse?.noAdsResponseURI = currentElementContent
            }

        case "AdSystem":
            ad?.adSystem = currentElementContent
            ad?.adSystemVersion = parseString(currentElementAttributes?["version"])

        case "AdParameters":
            creative?.adParameters = currentElementContent

        case "AdTitle":
            inlineAd?.title = currentElementContent

        case "Advertiser":
            inlineAd?.advertiser = currentElementContent

        case "Impression":
            ad?.impressionURIs.add(currentElementContent)

        case "Ad":
            if let ad {
                ad.identifier = parseString(adAttributes?["id"])

                if let sequenceString = adAttributes?["sequence"] {
                    let sequence = (sequenceString as NSString).intValue
                    if sequence != 0 {
                        ad.sequence = Int(sequence)
                    }
                }

                ad.ownerResponse = parsedResponse

                if let parsedResponse {
                    let ads = NSMutableArray(array: parsedResponse.vastAbstractAds)
                    ads.add(ad)
                    parsedResponse.vastAbstractAds = ads
                }
            } else {
                Log.error("Ad tag ending with no ad object.")
            }

            inlineAd = nil
            wrapperAd = nil
            ad = nil
            adAttributes = nil

        case "Creative":
            creative?.id = creativeAttributes?["id"]
            creative?.adId = creativeAttributes?["AdID"]

            if let sequenceString = creativeAttributes?["sequence"] {
                let sequence = (sequenceString as NSString).intValue
                if sequence != 0 {
                    creative?.sequence = Int(sequence)
                }
            }

            // doubleclick can produce empty Creative nodes
            if let creative {
                ad?.creatives.add(creative)
            }

            creative = nil
            creativeAttributes = nil

        case "Tracking":
            guard let event = currentElementAttributes?["event"] else {
                return
            }

            var vastTrackingEvents: VastTrackingEvents?

            if let companionAds = creative as? VastCreativeCompanionAds {
                if companionAds.companions.count > 0 {
                    let companion = companionAds.companions.lastObject as? VastCreativeCompanionAdsCompanion
                    vastTrackingEvents = companion?.trackingEvents
                }
            } else if let linearCreative = creative as? VastCreativeLinear {
                vastTrackingEvents = linearCreative.vastTrackingEvents
            } else if let nonLinearAds = creative as? VastCreativeNonLinearAds {
                if nonLinearAds.nonLinears.count > 0 {
                    let nonLinear = nonLinearAds.nonLinears.lastObject as? VastCreativeNonLinearAdsNonLinear
                    vastTrackingEvents = nonLinear?.vastTrackingEvents
                }
            } else if let verificationResource {
                if verificationResource.trackingEvents == nil {
                    verificationResource.trackingEvents = VastTrackingEvents()
                }

                vastTrackingEvents = verificationResource.trackingEvents
            }

            guard let vastTrackingEvents else {
                Log.error("No suitable tracking events object found to append contents of Tracking tag to")
                return
            }

            vastTrackingEvents.addTrackingURL(currentElementContent, event: event, attributes: currentElementAttributes)

        case "AdVerifications":
            if let verificationParameter {
                inlineAd?.verificationParameters = verificationParameter
            }
            verificationParameter = nil

        case "Verification":
            if let verificationResource {
                verificationParameter?.verificationResources.append(verificationResource)
            }

            verificationResource = nil

        case "JavaScriptResource":
            verificationResource?.url = currentElementContent

        // case "ExecutableResource":
            // Unsuported

        case "VerificationParameters":
            verificationResource?.params = currentElementContent

        case "Duration":
            if let linearCreative = creative as? VastCreativeLinear {
                linearCreative.duration = parseTimeInterval(currentElementContent)
            } else {
                Log.error("Duration tag found but creative not PBMVastCreativeLinear")
            }

        case "ClickThrough":
            if let linearCreative = creative as? VastCreativeLinear {
                linearCreative.clickThroughURI = currentElementContent
            } else {
                Log.error("Clickthrough tag found but creative not PBMVastCreativeLinear")
            }

        case "MediaFile":
            if let linearCreative = creative as? VastCreativeLinear {
                if linearCreative.mediaFiles.count > 0 {
                    let mediaFile = linearCreative.mediaFiles.lastObject as? VastMediaFile
                    mediaFile?.mediaURI = currentElementContent
                }
            } else {
                Log.error("MediaFile tag found but creative not PBMVastCreativeLinear")
            }

        case "StaticResource":
            parseResource(for: .staticResource)

        case "IFrameResource":
            parseResource(for: .iFrameResource)

        case "HTMLResource":
            parseResource(for: .htmlResource)

        case "ClickTracking", "CustomClick":
            guard let linearCreative = creative as? VastCreativeLinear else {
                Log.error("\(elementName) tag found but creative not PBMVastCreativeLinear")
                return
            }
            linearCreative.clickTrackingURIs.add(currentElementContent)

        case "IconClickThrough":
            guard let linearCreative = creative as? VastCreativeLinear else {
                Log.error("IconClickThrough tag found but creative not PBMVastCreativeLinear")
                return
            }

            if linearCreative.icons.count > 0 {
                let icon = linearCreative.icons.lastObject as? VastIcon
                icon?.clickThroughURI = currentElementContent
            }

        case "IconClickTracking":
            guard let linearCreative = creative as? VastCreativeLinear else {
                Log.error("IconClickTracking tag found but creative not PBMVastCreativeLinear")
                return
            }

            if linearCreative.icons.count > 0 {
                let icon = linearCreative.icons.lastObject as? VastIcon
                icon?.clickTrackingURIs.add(currentElementContent)
            }

        case "IconViewTracking":
            guard let linearCreative = creative as? VastCreativeLinear else {
                Log.error("IconViewTracking tag found but creative not PBMVastCreativeLinear")
                return
            }

            if linearCreative.icons.count > 0 {
                let icon = linearCreative.icons.lastObject as? VastIcon
                icon?.viewTrackingURI = currentElementContent
            }

        case "CompanionClickThrough":
            guard let companionAds = creative as? VastCreativeCompanionAds else {
                Log.error("CompanionClickThrough tag found but creative not PBMVastCreativeCompanionAds")
                return
            }

            if companionAds.companions.count > 0 {
                let companion = companionAds.companions.lastObject as? VastCreativeCompanionAdsCompanion
                companion?.clickThroughURI = currentElementContent
            }

        case "CompanionClickTracking":
            guard let companionAds = creative as? VastCreativeCompanionAds else {
                Log.error("CompanionClickTracking tag found but creative not PBMVastCreativeCompanionAds")
                return
            }

            if companionAds.companions.count > 0 {
                let companion = companionAds.companions.lastObject as? VastCreativeCompanionAdsCompanion
                companion?.clickTrackingURIs.add(currentElementContent)
            }

        case "NonLinearClickThrough":
            guard let nonLinearAds = creative as? VastCreativeNonLinearAds else {
                Log.error("NonLinearClickThrough tag found but creative not PBMVastCreativeNonLinearAds")
                return
            }

            if nonLinearAds.nonLinears.count > 0 {
                let nonLinear = nonLinearAds.nonLinears.lastObject as? VastCreativeNonLinearAdsNonLinear
                nonLinear?.clickThroughURI = currentElementContent
            } else {
                Log.error("NonLinearClickThrough tag found but no NonLinear objects to append content to")
            }

        case "NonLinearClickTracking":
            guard let nonLinearAds = creative as? VastCreativeNonLinearAds else {
                Log.error("NonLinearClickTracking tag found but creative not PBMVastCreativeNonLinearAds")
                return
            }

            if nonLinearAds.nonLinears.count > 0 {
                let nonLinear = nonLinearAds.nonLinears.lastObject as? VastCreativeNonLinearAdsNonLinear
                nonLinear?.clickTrackingURIs.add(currentElementContent)
            } else {
                Log.error("NonLinearClickTracking tag found but no NonLinear objects to append content to")
            }

        case "VASTAdTagURI":
            wrapperAd?.vastURI = currentElementContent

        default:
            break
        }

        if !elementPath.isEmpty {
            elementPath.removeLast()
        } else {
            Log.error("elementPath unexpectedly empty")
        }

        currentElementAttributes = nil
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        currentElementContent += trimmedString
    }

    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        // this reports a CDATA block to the delegate as a Data.
        guard let string = String(data: CDATABlock, encoding: .utf8) else {
            return
        }

        // Trim CDATA Blocks. Normally you don't alter CDATA blocks at all, but we're getting URLs
        // padded with whitespace inside of CDATA blocks.
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        currentElementContent += trimmedString
    }

    // MARK: - Helper Methods

    func extractCreativeContainer() -> VastResourceContainer? {
        var container: VastResourceContainer?

        if let linearCreative = creative as? VastCreativeLinear {
            if let icon = linearCreative.icons.lastObject as? VastIcon {
                container = icon
            }
        } else if let companionAds = creative as? VastCreativeCompanionAds {
            if let companion = companionAds.companions.lastObject as? VastCreativeCompanionAdsCompanion {
                container = companion
            }
        } else if let nonLinearAds = creative as? VastCreativeNonLinearAds {
            if let nonLinear = nonLinearAds.nonLinears.lastObject as? VastCreativeNonLinearAdsNonLinear {
                container = nonLinear
            }
        }

        return container
    }
}
