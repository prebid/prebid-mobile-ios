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

@objc(PBMExternalLinkHandler) @_spi(PBMInternal) public
class ExternalLinkHandler: NSObject {

    private let primaryUrlOpener: ExternalURLOpenerBlock
    private let deepLinkUrlOpener: ExternalURLOpenerBlock

    @objc public let trackingUrlVisitor: TrackingURLVisitorBlock

    @available(*, unavailable)
    override init() {
        fatalError("init() is unavailable")
    }

    @objc(initWithPrimaryUrlOpener:deepLinkUrlOpener:trackingUrlVisitor:)
    public init(
        primaryUrlOpener: @escaping ExternalURLOpenerBlock,
        deepLinkUrlOpener: @escaping ExternalURLOpenerBlock,
        trackingUrlVisitor: @escaping TrackingURLVisitorBlock
    ) {
        self.primaryUrlOpener = primaryUrlOpener
        self.deepLinkUrlOpener = deepLinkUrlOpener
        self.trackingUrlVisitor = trackingUrlVisitor
        super.init()
    }

    @objc(openExternalUrl:trackingUrls:completion:onClickthroughExitBlock:)
    public func openExternalUrl(
        _ url: URL,
        trackingUrls: [String]?,
        completion: @escaping URLOpenResultHandlerBlock,
        onClickthroughExitBlock: VoidBlock?
    ) {
        primaryUrlOpener(url, { success in
            if success {
                self.trackingUrlVisitor(trackingUrls ?? [])
                completion(true)
            } else {
                completion(false)
            }
        }, onClickthroughExitBlock)
    }

    @objc public var asDeepLinkHandler: ExternalLinkHandler {
        ExternalLinkHandler(
            primaryUrlOpener: deepLinkUrlOpener,
            deepLinkUrlOpener: deepLinkUrlOpener,
            trackingUrlVisitor: trackingUrlVisitor
        )
    }

    @objc(handlerByAddingUrlOpenAttempter:)
    public func handlerByAddingUrlOpenAttempter(
        _ urlOpenAttempter: @escaping URLOpenAttempterBlock
    ) -> ExternalLinkHandler {
        let currentUrlOpener = primaryUrlOpener
        let newCombinedOpener: ExternalURLOpenerBlock = { url, completion, onClickthroughExitBlock in
            urlOpenAttempter(url) { willOpenURL in
                if willOpenURL {
                    return ExternalURLOpenCallbacks(
                        urlOpenedCallback: completion,
                        onClickthroughExitBlock: onClickthroughExitBlock
                    )
                } else {
                    currentUrlOpener(url, completion, onClickthroughExitBlock)
                    return ExternalURLOpenCallbacks(
                        urlOpenedCallback: { _ in /* nop */ },
                        onClickthroughExitBlock: nil
                    )
                }
            }
        }
        return ExternalLinkHandler(
            primaryUrlOpener: newCombinedOpener,
            deepLinkUrlOpener: deepLinkUrlOpener,
            trackingUrlVisitor: trackingUrlVisitor
        )
    }
}
