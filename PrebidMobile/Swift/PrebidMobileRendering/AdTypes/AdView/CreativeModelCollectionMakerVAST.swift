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

// ObjC name preserved for the bridge; still called from PBMAdLoadManagerVAST.m
@objc(PBMCreativeModelCollectionMakerVAST) @_spi(PBMInternal) public
class CreativeModelCollectionMakerVAST: NSObject {

    @objc public var adConfiguration: AdConfiguration
    @objc public var serverConnection: PrebidServerConnectionProtocol

    @objc public init(serverConnection: PrebidServerConnectionProtocol,
                      adConfiguration: AdConfiguration) {
        self.adConfiguration = adConfiguration
        self.serverConnection = serverConnection
        super.init()
    }

    // The success/failure blocks replace the ObjC `PBMCreativeModelMakerSuccessCallback` /
    // `PBMCreativeModelMakerFailureCallback` typedefs (deleted with PBMCreativeModelMakerResult.h).
    @objc(makeModels:successCallback:failureCallback:)
    public func makeModels(_ adRequestResponse: AdRequestResponseVAST,
                           successCallback: ([CreativeModel]) -> Void,
                           failureCallback: (Error) -> Void) {
        do {
            let models = try createCreativeModels(from: adRequestResponse.ads)
            successCallback(models)
        } catch {
            failureCallback(error)
        }
    }

    // MARK: - Internal Methods

    // Same code and message as `PBMError createError:description:statusCode:`, which also logged the error.
    private func makeError(_ description: String, code: PBMErrorCode) -> PBMError {
        let error = PBMError.error(description: description, statusCode: code)
        Log.error("\(error)")
        return error
    }

    private func createCreativeModels(from ads: [VastAbstractAd]?) throws -> [CreativeModel] {
        var errorMessage = "No creative"
        var creatives = [CreativeModel]()
        // The ObjC cast the first ad to `PBMVastInlineAd` unchecked; a wrapper ad as first ad raised an
        // unrecognized selector on `verificationParameters`.
        guard let vastAd = ads?.first as? VastInlineAd, vastAd.creatives.count > 0 else {
            throw makeError(errorMessage, code: .generalLinear)
        }

        // Create the Linear Creative Model
        // VAST does not mandate creative order: CompanionAds / NonLinearAds may precede the Linear creative,
        // so pick the first Linear rather than assuming it's firstObject.
        guard let creative = vastAd.creatives.compactMap({ $0 as? VastCreativeLinear }).first else {
            throw makeError(errorMessage, code: .generalLinear)
        }

        guard let bestMediaFile = creative.bestMediaFile() else {
            errorMessage = "No suitable media file"
            throw makeError(errorMessage, code: .fileNotFound)
        }

        let creativeModel = try createCreativeModel(ad: vastAd, creative: creative, mediaFile: bestMediaFile)
        creatives.append(creativeModel)

        // Creative the Companion Ads creative model
        // Per the Vast spec, we have either 1 Linear or NonLinear, the rest are the companion ads/end cards.
        let companionItems = vastAd.creatives.compactMap { $0 as? VastCreativeCompanionAds }

        if companionItems.count > 0 {
            // Now try to create the companion items creatives.
            // Create a model of the best fitting companion ad.
            if let creativeModelCompanion = createCompanionCreativeModel(ad: vastAd, companionAds: companionItems) {
                // There is at least 1 companion.  Set the flag so that when the initial video creative has completed
                // display, the appropriate view controllers will prevent the "close" button and the learn more after the video has
                // finished, it will instead display the endcard.
                creativeModel.hasCompanionAd = true
                creatives.append(creativeModelCompanion)
            }
        }

        return creatives
    }

    private func createCreativeModel(ad vastAd: VastInlineAd,
                                     creative: VastCreativeLinear,
                                     mediaFile: VastMediaFile) throws -> CreativeModel {
        if creative.duration <= 0 {
            throw makeError("Creative duration is invalid", code: .general)
        }

        if let maxVideoDuration = adConfiguration.videoControlsConfig.maxVideoDuration,
           creative.duration > maxVideoDuration.doubleValue {
            throw makeError("Creative duration is bigger than maximum available playback time obtained from server response.",
                            code: .general)
        } else if let maxDuration = adConfiguration.videoParameters.maxDuration?.value,
                  maxDuration != 0,
                  creative.duration > Double(maxDuration) {
            throw makeError("Creative duration is bigger than maximum available playback time set by the user.",
                            code: .general)
        }

        let creativeModel = CreativeModel(adConfiguration: adConfiguration)
        creativeModel.eventTracker = AdModelEventTracker(creativeModel: creativeModel, serverConnection: serverConnection)
        creativeModel.verificationParameters = vastAd.verificationParameters

        // Pack successful data into a CreativeModel
        creativeModel.videoFileURL = mediaFile.mediaURI
        creativeModel.displayDurationInSeconds = NSNumber(value: creative.duration)
        creativeModel.skipOffset = creative.skipOffset
        creativeModel.width = mediaFile.width
        creativeModel.height = mediaFile.height

        var trackingURLs = creative.vastTrackingEvents.trackingEvents

        // Store the impression URIs so that can be fired at the appropriate time.
        let impressionKey = TrackingEventDescription.getDescription(.impression)
        trackingURLs[impressionKey] = vastAd.impressionURIs.compactMap { $0 as? String }
        let clickKey = TrackingEventDescription.getDescription(.click)
        trackingURLs[clickKey] = creative.clickTrackingURIs.compactMap { $0 as? String }

        creativeModel.trackingURLs = trackingURLs
        creativeModel.clickThroughURL = creative.clickThroughURI

        return creativeModel
    }

    private func createCompanionCreativeModel(ad vastAd: VastInlineAd,
                                              companionAds: [VastCreativeCompanionAds]) -> CreativeModel? {
        let creativeModel = CreativeModel(adConfiguration: adConfiguration)
        creativeModel.eventTracker = AdModelEventTracker(creativeModel: creativeModel, serverConnection: serverConnection)
        creativeModel.verificationParameters = vastAd.verificationParameters

        guard let companionAd = companionAds.first, companionAd.companions.count > 0 else {
            return nil
        }

        // get the most appropriate companion from the list.
        guard let companion = mostAppropriateCompanion(companionAd) else {
            return nil
        }
        let resource: String?
        switch companion.resourceType {
        case .staticResource:
            // image. build html around resource
            resource = buildStaticResource(companion)
        case .iFrameResource:
            resource = companion.resource
        case .htmlResource:
            resource = companion.resource
        @unknown default:
            // unrecognized companion type.
            return nil
        }

        guard let resource else {
            return nil
        }

        creativeModel.html = resource
        creativeModel.width = companion.width
        creativeModel.height = companion.height
        creativeModel.clickThroughURL = companion.clickThroughURI

        // Store the impression URIs so that can be fired at the appropriate time.
        var trackingURLs = companion.trackingEvents.trackingEvents
        let companionClickKey = TrackingEventDescription.getDescription(.companionClick)

        // Create a companion array if it doesn't already exist.
        let trackingArray = trackingURLs[companionClickKey] ?? []
        let clickTrackingURIs = companion.clickTrackingURIs.compactMap { $0 as? String }
        // Save the the tracking urls in the array.
        trackingURLs[companionClickKey] = trackingArray + clickTrackingURIs

        let clickKey = TrackingEventDescription.getDescription(.click)
        trackingURLs[clickKey] = clickTrackingURIs

        creativeModel.trackingURLs = trackingURLs

        // tag this creative model as an end card.
        creativeModel.isCompanionAd = true
        return creativeModel
    }

    private func mostAppropriateCompanion(_ companionAd: VastCreativeCompanionAds) -> VastCreativeCompanionAdsCompanion? {
        // currently we only return the first option.
        // Todo: add additional logic for the most appropriate using the following:
        //  * size
        //  * type
        companionAd.companions.firstObject as? VastCreativeCompanionAdsCompanion
    }

    private func buildStaticResource(_ companion: VastCreativeCompanionAdsCompanion) -> String {
        // `%@` with a nil object printed "(null)" through ObjC `stringWithFormat:`.
        String(format: PrebidConstants.companionHTMLTemplate,
               companion.clickThroughURI ?? "(null)",
               companion.resource ?? "(null)")
    }
}
