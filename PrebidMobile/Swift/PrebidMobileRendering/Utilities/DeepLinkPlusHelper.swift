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

@objc(PBMDeepLinkPlusHelper) @_spi(PBMInternal) public
class DeepLinkPlusHelper: NSObject {

    // Test seams (the ObjC `+Testing` category). Strong, like the static ivars that backed them.
    static var application: PBMUIApplicationProtocol?
    static var connection: PrebidServerConnectionProtocol?

    @available(*, unavailable)
    override init() {
        fatalError("init() is unavailable")
    }

    // MARK: - Public API

    @objc(isDeepLinkPlusURL:)
    public static func isDeepLinkPlusURL(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "deeplink+"
    }

    @objc(tryHandleDeepLinkPlus:completion:)
    public static func tryHandleDeepLinkPlus(
        _ url: URL,
        completion: @escaping (_ visited: Bool, _ fallbackURL: URL?, _ trackingURLs: [URL]?) -> Void
    ) {
        let urlOpener: ExternalURLOpenerBlock
        if let application = application ?? Functions.resolvedApplication {
            urlOpener = ExternalURLOpeners.applicationAsExternalUrlOpener(application)
        } else {
            // Host-less (no UIApplication): ObjC messaged a nil application, so nothing was opened, the
            // result handler never ran and only the exit block fired.
            urlOpener = { _, _, onClickthroughExitBlock in
                onClickthroughExitBlock?()
            }
        }

        let trackingUrlVisitor = TrackingURLVisitors.connectionAsTrackingURLVisitor(
            connection ?? PrebidServerConnection.shared
        )

        let externalLinkHandler = ExternalLinkHandler(
            primaryUrlOpener: urlOpener,
            deepLinkUrlOpener: urlOpener,
            trackingUrlVisitor: trackingUrlVisitor
        )

        tryHandleDeepLinkPlus(
            url,
            externalLinkHandler: externalLinkHandler,
            completion: completion,
            onClickthroughExitBlock: nil
        )
    }

    @objc(visitTrackingURLs:)
    public static func visitTrackingURLs(_ trackingURLs: [URL]) {
        visitTrackingUrlStrings(urlArrayToUrlStringArray(trackingURLs) ?? [])
    }

    static func visitTrackingUrlStrings(_ trackingUrlStrings: [String]) {
        let visitorBlock = TrackingURLVisitors.connectionAsTrackingURLVisitor(
            connection ?? PrebidServerConnection.shared
        )
        visitorBlock(trackingUrlStrings)
    }

    static func isDeepLinkURL(_ url: URL) -> Bool {
        let allowedSchemes = ["http", "https", "file"]
        if let scheme = url.scheme?.lowercased(), allowedSchemes.contains(scheme) {
            return false
        }
        return true
    }

    // MARK: - Private Helpers

    private static func tryHandleDeepLinkPlus(
        _ url: URL,
        externalLinkHandler: ExternalLinkHandler,
        completion: @escaping (_ visited: Bool, _ fallbackURL: URL?, _ trackingURLs: [URL]?) -> Void,
        onClickthroughExitBlock: VoidBlock?
    ) {
        guard let deepLinkPlus = DeepLinkPlus.deepLinkPlus(with: url) else {
            completion(false, nil, nil)
            return
        }

        let deepLinkHandler = externalLinkHandler.asDeepLinkHandler

        deepLinkHandler.openExternalUrl(
            deepLinkPlus.primaryURL,
            trackingUrls: urlArrayToUrlStringArray(deepLinkPlus.primaryTrackingURLs),
            completion: { primaryLinkHandled in
                if primaryLinkHandled {
                    completion(true, nil, nil)
                } else if let fallbackURL = deepLinkPlus.fallbackURL {
                    if isDeepLinkURL(fallbackURL) {
                        deepLinkHandler.openExternalUrl(
                            fallbackURL,
                            trackingUrls: urlArrayToUrlStringArray(deepLinkPlus.fallbackTrackingURLs),
                            completion: { fallbackLinkHandled in
                                completion(fallbackLinkHandled, nil, nil)
                            },
                            onClickthroughExitBlock: onClickthroughExitBlock
                        )
                    } else {
                        completion(false, fallbackURL, deepLinkPlus.fallbackTrackingURLs)
                    }
                } else {
                    completion(false, nil, nil)
                }
            },
            onClickthroughExitBlock: onClickthroughExitBlock
        )
    }

    private static func urlArrayToUrlStringArray(_ urlArray: [URL]?) -> [String]? {
        urlArray?.map { $0.absoluteString }
    }
}
