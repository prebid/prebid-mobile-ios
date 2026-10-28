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

// ObjC name preserved so the runtime class name stays stable; no ObjC caller remains.
class VastAdsBuilder: NSObject {

    // Replaces the ObjC `PBMVastAdsBuilderCompletionBlock` typedef.
    typealias Completion = ([VastAbstractAd]?, Error?) -> Void

    // Replaces the ObjC `PBMVastAdsBuilderWrapperCompletionBlock` typedef (private to the .m).
    private typealias WrapperCompletion = (Error?) -> Void

    private static let builderFailedMessage = "VAST error: the ads builder is failed"

    private let dispatchQueue = DispatchQueue(label: "PBMVastLoaderQueue")
    private let serverConnection: PrebidServerConnectionProtocol
    private var requestsPending = 0
    private let maximumWrapperDepth = 5     // Per VAST 4.0 spec section 2.3.4.1
    private var rootResponse: VastResponse?

    // MARK: - Initialization

    init(connection serverConnection: PrebidServerConnectionProtocol) {
        self.serverConnection = serverConnection
        super.init()
    }

    // MARK: - Public

    func buildAds(_ data: Data, completion completionBlock: @escaping Completion) {
        buildAds(data, wrapperAd: nil) { [weak self] error in
            guard let self else {
                completionBlock(nil, PBMError.error(description: Self.builderFailedMessage, statusCode: .undefined))
                return
            }

            if let error {
                completionBlock(nil, error)
                return
            }

            do {
                completionBlock(try self.extractAds(), nil)
            } catch {
                completionBlock(nil, error)
            }
        }
    }

    func checkHasNoAdsAndFireURIs(vastResponse: VastResponse) -> Bool {

        var firedNoAdsURI = false

        // An empty response reports 303 to its response-level Error URI and to the wrappers that led to it.

        if vastResponse.vastAbstractAds.count == 0 {

            // Walk the response chain, selecting only the wrapper that led to the current response.
            // Other wrappers in the parent response may belong to successful sibling branches.

            var parent: VastResponse? = vastResponse
            while let current = parent {

                if let noAdsResponseURI = current.noAdsResponseURI {
                    serverConnection.fireAndForget(VastErrorCode.noAdAfterWrappers.replacingMacro(in: noAdsResponseURI))
                }

                // Avoid infinite loop
                if current.parentResponse === current {
                    break
                }

                if let parentResponse = current.parentResponse,
                   let wrapper = parentResponse.vastAbstractAds.compactMap({ $0 as? VastWrapperAd })
                    .first(where: { $0.vastResponse === current }) {
                    for errorURI in wrapper.errorURIs where !errorURI.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        serverConnection.fireAndForget(VastErrorCode.noAdAfterWrappers.replacingMacro(in: errorURI))
                    }
                }

                parent = current.parentResponse
            }
            firedNoAdsURI = true
        } else {

            for ad in vastResponse.vastAbstractAds {

                // If the Ad is a wrapper
                if let unwrappedVASTWrapper = ad as? VastWrapperAd {

                    // And it has a response
                    if let unwrappedVastResponse = unwrappedVASTWrapper.vastResponse {
                        let childHasNoAds = checkHasNoAdsAndFireURIs(vastResponse: unwrappedVastResponse)
                        firedNoAdsURI = firedNoAdsURI || childHasNoAds
                    } else {
                        Log.error("No vastResponse on Wrapper")
                    }
                }
            }
        }

        return firedNoAdsURI
    }

    // MARK: - Private

    private func buildAds(_ data: Data, wrapperAd: VastWrapperAd?, completion completionBlock: @escaping WrapperCompletion) {

        if let wrapperAd, wrapperAd.depth > maximumWrapperDepth {
            let error = PBMError.error(
                description: "Wrapper limit reached, as defined by the video player. Too many Wrapper responses have been received with no InLine response.",
                statusCode: .undefined
            )
            completionBlock(error)
            return
        }

        let parser = VastParser()
        guard let parsedResponse = parser.parseAdsResponse(data) else {
            let vastString = String(data: data, encoding: .utf8) ?? "(null)"
            let message = "VAST Parsing failed. XML was:  \(vastString)"
            completionBlock(PBMError.error(description: message, statusCode: .undefined))
            return
        }

        handleResponse(parsedResponse, forWrapperAd: wrapperAd) { [weak self] error in
            guard let self else {
                completionBlock(PBMError.error(description: Self.builderFailedMessage, statusCode: .undefined))
                return
            }

            if let error {
                completionBlock(error)
                return
            }

            if wrapperAd != nil {
                self.dispatchQueue.sync {
                    self.requestsPending -= 1
                }

                completionBlock(nil)
            } else if self.requestsPending == 0 {
                completionBlock(nil)
            }
        }
    }

    private func requestAds(_ vastURL: String?, forWrapperAd wrapperAd: VastWrapperAd, completion: @escaping WrapperCompletion) {

        dispatchQueue.sync {
            requestsPending += 1
        }

        // `self` is captured strongly by this callback, as in the ObjC (only the blocks around it were weakified).
        serverConnection.get(vastURL, timeout: PrebidConstants.CONNECTION_TIMEOUT_DEFAULT) { serverResponse in
            if let error = serverResponse.error {
                completion(error)
                return
            }

            if serverResponse.statusCode != 200 {
                // The status code is an arbitrary HTTP value, not a `PBMErrorCode`, so
                // it goes through the raw-`Int` initializer.
                completion(PBMError(message: "Server responded with status code \(serverResponse.statusCode)",
                                    code: serverResponse.statusCode))
                return
            }

            // A nil `rawData` used to reach the nonnull ObjC parameter; empty data fails to parse the same way.
            self.buildAds(serverResponse.rawData ?? Data(), wrapperAd: wrapperAd, completion: completion)
        }
    }

    private func handleResponse(_ response: VastResponse, forWrapperAd wrapperAd: VastWrapperAd?, completion completionBlock: @escaping WrapperCompletion) {

        if let wrapperAd {
            // Assign nextResponse and parentResponse
            wrapperAd.vastResponse = response
            response.parentResponse = wrapperAd.ownerResponse

            // If multiple ads are disabled, drop everything but the first ad with a sequence of 0.
            if !wrapperAd.allowMultipleAds {
                if let firstAd = response.vastAbstractAds.first(where: { $0.sequence == 0 }) {
                    response.vastAbstractAds = [firstAd]
                }
            }

            // If the parent asked us not to follow wrappers, remove any wrappers we find in the response.
            if !wrapperAd.followAdditionalWrappers {
                response.vastAbstractAds = response.vastAbstractAds.filter { !($0 is VastWrapperAd) }
            }

            // Copy parent's allowMultipleAds setting to child wrappers
            for case let wrapper as VastWrapperAd in response.vastAbstractAds {
                wrapper.allowMultipleAds = wrapperAd.allowMultipleAds
            }
        } else {
            // If parentWrapper is nil, this is the root response.
            rootResponse = response
        }

        // If we're not at the max depth then add a request for each wrapper.
        var hasWrappers = false
        for case let responseWrapperAd as VastWrapperAd in response.vastAbstractAds {
            hasWrappers = true

            responseWrapperAd.depth = (wrapperAd?.depth ?? 0) + 1

            requestAds(responseWrapperAd.vastURI, forWrapperAd: responseWrapperAd, completion: completionBlock)
        }

        if !hasWrappers {
            completionBlock(nil)
        }
    }

    private func hasValidMedia(_ ads: [VastAbstractAd]) -> Bool {
        for case let ad as VastInlineAd in ads where ad.playableLinearCreative() != nil {
            return true
        }
        return false
    }

    // Matches `+[PBMError createError:description:statusCode:]`, which logged the error it created.
    private static func error(description: String, statusCode: PBMErrorCode) -> PBMError {
        let error = PBMError.error(description: description, statusCode: statusCode)
        Log.error("\(error)")
        return error
    }

    private func extractAds() throws -> [VastAbstractAd] {
        guard let rootResponse else {
            throw Self.error(description: "No Root Response", statusCode: .fileNotFound)
        }

        // check for ads & media and fire appropriate URIs
        if checkHasNoAdsAndFireURIs(vastResponse: rootResponse) {
            throw Self.error(description: "One or more responses had no ads", statusCode: .generalLinear)
        }

        let ads = try rootResponse.flattenResponse()

        if !hasValidMedia(ads) {
            throw Self.error(description: "No Valid Media", statusCode: .fileNotFound)
        }

        return ads
    }
}
