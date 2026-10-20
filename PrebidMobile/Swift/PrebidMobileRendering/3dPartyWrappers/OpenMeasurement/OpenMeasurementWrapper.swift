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
import UIKit
import WebKit
import OMSDK_Prebidorg

/// Creates Open Measurement sessions. OMID types are never exposed publicly.
///
/// `internal`: the ObjC original was a private header, never public API. It conforms to the public `OMSessionWrapper`.
class OpenMeasurementWrapper: NSObject, OMSessionWrapper {

    // MARK: - Constants

    private static let partnerNameValue = "Prebidorg"
    private static let jsLibURLValue = "https://my.server.com/omsdk.js"
    private static let customRefIdValue = ""

    // MARK: - Properties

    static let shared = OpenMeasurementWrapper()

    /// Injectable so tests can make partner creation fail.
    let partnerName: String
    var jsLibURL: String { Self.jsLibURLValue }
    var customRefId: String { Self.customRefIdValue }

    var partner: OMIDPrebidorgPartner?

    var libraryManager: PrebidJSLibraryManager?

    // MARK: - Initialization

    override convenience init() {
        self.init(partnerName: Self.partnerNameValue)
    }

    init(partnerName: String) {
        self.partnerName = partnerName
        libraryManager = PrebidJSLibraryManager.shared
        super.init()
        initializeOMSDK()
    }

    // MARK: - OMSessionWrapper

    func injectJSLib(_ html: String, error: NSErrorPointer) -> String? {
        guard let jsLib = fetchOMSDKScript() else {
            let sessionError = PBMError.error(description: "The js lib for Open Measurement is not loaded.")
            if let error {
                error.pointee = sessionError
                Log.error("\(sessionError)")
            }
            return nil
        }

        do {
            return try OMIDPrebidorgScriptInjector.injectScriptContent(jsLib, intoHTML: html)
        } catch let injectionError as NSError {
            error?.pointee = injectionError
            return nil
        }
    }

    func initializeWebViewSession(_ webView: WKWebView, contentUrl: String?) -> OMSession? {

        let context: OMIDPrebidorgAdSessionContext
        do {
            guard let partner else {
                throw PBMError.error(description: "The Open Measurement partner is not created.")
            }
            context = try OMIDPrebidorgAdSessionContext(partner: partner,
                                                        webView: webView,
                                                        contentUrl: contentUrl,
                                                        customReferenceIdentifier: customRefId)
        } catch {
            Log.error("Unable to create Open Measurement session context with error: \(error.localizedDescription)")
            return nil
        }

        let configuration: OMIDPrebidorgAdSessionConfiguration
        do {
            configuration = try OMIDPrebidorgAdSessionConfiguration(creativeType: .htmlDisplay,
                                                                    impressionType: .onePixel,
                                                                    impressionOwner: .nativeOwner,
                                                                    mediaEventsOwner: .noneOwner,
                                                                    isolateVerificationScripts: false)
        } catch {
            Log.error("Unable to create Open Measurement session configuration with error: \(error.localizedDescription)")
            return nil
        }

        // The ObjC original logged an `NSError` that was never assigned; the session initializer logs the real cause.
        guard let session = OpenMeasurementSession(context: context, configuration: configuration) else {
            Log.error("Unable to create Open Measurement session")
            return nil
        }

        session.setupMainView(webView)

        return session
    }

    func initializeNativeVideoSession(_ videoView: UIView,
                                      verificationParameters: VideoVerificationParameters?) -> OMSession? {

        guard let jsLib = fetchOMSDKScript() else {
            Log.error("Open Measurement SDK can't work without valid js script")
            return nil
        }

        let context: OMIDPrebidorgAdSessionContext
        do {
            guard let partner else {
                throw PBMError.error(description: "The Open Measurement partner is not created.")
            }
            context = try OMIDPrebidorgAdSessionContext(partner: partner,
                                                        script: jsLib,
                                                        resources: scriptResources(from: verificationParameters),
                                                        contentUrl: nil,
                                                        customReferenceIdentifier: nil)
        } catch {
            Log.error("Unable to create Open Measurement session context with error: \(error.localizedDescription)")
            return nil
        }

        let configuration: OMIDPrebidorgAdSessionConfiguration
        do {
            configuration = try OMIDPrebidorgAdSessionConfiguration(creativeType: .video,
                                                                    impressionType: .onePixel,
                                                                    impressionOwner: .nativeOwner,
                                                                    mediaEventsOwner: .nativeOwner,
                                                                    isolateVerificationScripts: false)
        } catch {
            Log.error("Unable to create Open Measurement session configuration with error: \(error.localizedDescription)")
            return nil
        }

        guard let session = OpenMeasurementSession(context: context, configuration: configuration) else {
            Log.error("Unable to create Open Measurement session")
            return nil
        }

        session.setupMainView(videoView)

        return session
    }

    func initializeNativeDisplaySession(_ view: UIView,
                                        omidJSUrl: String,
                                        vendorKey: String?,
                                        parameters verificationParameters: String?) -> OMSession? {

        guard let jsLib = fetchOMSDKScript() else {
            Log.error("Open Measurement SDK can't work without valid js script")
            return nil
        }

        let resources = scriptResources(from: omidJSUrl, vendorKey: vendorKey, parameters: verificationParameters)

        let context: OMIDPrebidorgAdSessionContext
        do {
            guard let partner else {
                throw PBMError.error(description: "The Open Measurement partner is not created.")
            }
            context = try OMIDPrebidorgAdSessionContext(partner: partner,
                                                        script: jsLib,
                                                        resources: resources,
                                                        contentUrl: nil,
                                                        customReferenceIdentifier: nil)
        } catch {
            Log.error("Unable to create Open Measurement session context with error: \(error.localizedDescription)")
            return nil
        }

        let configuration: OMIDPrebidorgAdSessionConfiguration
        do {
            configuration = try OMIDPrebidorgAdSessionConfiguration(creativeType: .nativeDisplay,
                                                                    impressionType: .onePixel,
                                                                    impressionOwner: .nativeOwner,
                                                                    mediaEventsOwner: .noneOwner,
                                                                    isolateVerificationScripts: false)
        } catch {
            Log.error("Unable to create Open Measurement session configuration with error: \(error.localizedDescription)")
            return nil
        }

        guard let session = OpenMeasurementSession(context: context, configuration: configuration) else {
            Log.error("Unable to create Open Measurement session")
            return nil
        }

        session.setupMainView(view)

        return session
    }

    // MARK: - Internal

    private func initializeOMSDK() {
        // The ObjC original logged an `NSError` that was never assigned; `activate()` reports nothing else.
        if !OMIDPrebidorgSDK.shared.activate() {
            Log.error("Prebid SDK can't initialize Open Measurement SDK")
        }

        partner = OMIDPrebidorgPartner(name: partnerName, versionString: Functions.sdkVersion)
    }

    func fetchOMSDKScript() -> String? {
        libraryManager?.getOMSDKLibrary()
    }

    private func scriptResources(from verificationParameters: VideoVerificationParameters?) -> [OMIDPrebidorgVerificationScriptResource] {
        var scripts = [OMIDPrebidorgVerificationScriptResource]()

        for vastResource in verificationParameters?.verificationResources ?? [] {
            guard let urlString = vastResource.url, let vendorKey = vastResource.vendorKey, let params = vastResource.params else {
                Log.error("Invalid Verification Resource. All properties should be provided. Url: \(vastResource.url ?? "(null)"), vendorKey: \(vastResource.vendorKey ?? "(null)"), params: \(vastResource.params ?? "(null)")")
                continue
            }

            // `NSURL(string:)` as in the ObjC original: it accepts strings `URL(string:)` rejects (S7.3-D).
            guard let url = NSURL(string: urlString) as URL? else {
                Log.error("The URL for OM Verification Resource is invalid. Url: \(urlString)")
                continue
            }

            guard let resource = OMIDPrebidorgVerificationScriptResource(url: url, vendorKey: vendorKey, parameters: params) else {
                Log.error("Can't create OM Verification Resource. Url: \(urlString), vendorKey: \(vendorKey), params: \(params)")
                continue
            }

            scripts.append(resource)
        }

        return scripts
    }

    private func scriptResources(from omidJSUrl: String?,
                                 vendorKey: String?,
                                 parameters: String?) -> [OMIDPrebidorgVerificationScriptResource] {

        guard let omidJSUrl, let vendorKey, let parameters else {
            Log.error("Invalid Verification Resource. All properties should be provided. Url: \(omidJSUrl ?? "(null)"), vendorKey: \(vendorKey ?? "(null)"), params: \(parameters ?? "(null)")")
            return []
        }

        guard let url = NSURL(string: omidJSUrl) as URL? else {
            Log.error("The URL for OM Verification Resource is invalid. Url: \(omidJSUrl)")
            return []
        }

        guard let resource = OMIDPrebidorgVerificationScriptResource(url: url, vendorKey: vendorKey, parameters: parameters) else {
            Log.error("Can't create OM Verification Resource. Url: \(omidJSUrl), vendorKey: \(vendorKey), params: \(parameters)")
            return []
        }

        return [resource]
    }
}
