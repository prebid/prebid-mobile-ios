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

// ObjC class name preserved so Factory.WinNotifierType = NSClassFromString("PBMWinNotifier_Objc") resolves at runtime
@objc(PBMWinNotifier_Objc) @_spi(PBMInternal) public
class WinNotifierImpl: NSObject, WinNotifier {

    public required override init() {
        super.init()
    }

    public static func notifyThroughConnection(
        _ connection: PrebidServerConnectionProtocol,
        winningBid bid: Bid,
        callback adMarkupConsumer: @escaping AdMarkupStringHandler
    ) {
        let macrosHelper = ORTBMacrosHelper(bid: bid)

        func chainNotificationAction(
            notificationUrl: String?,
            onResult: @escaping AdMarkupStringHandler
        ) -> AdMarkupStringHandler {
            guard let notificationUrl = notificationUrl else {
                return onResult
            }
            return { adMarkup in
                if let adMarkup = adMarkup {
                    onResult(adMarkup)
                    connection.download(notificationUrl) { _ in /* nop */ }
                } else {
                    connection.download(notificationUrl) { response in
                        var adMarkupFromResponse: String?
                        if response.error == nil,
                           let rawData = response.rawData,
                           let rawResponseString = String(data: rawData, encoding: .utf8) {
                            let rawAdMarkupString = adMarkupString(fromResponse: rawResponseString)
                            adMarkupFromResponse = macrosHelper.replaceMacros(in: rawAdMarkupString)
                        }
                        onResult(adMarkupFromResponse)
                    }
                }
            }
        }

        let targeting = bid.targetingInfo ?? [:]
        let uuidUrl = cacheUrl(fromTargeting: targeting, idKey: "hb_uuid")
        let cacheUrlValue = cacheUrl(fromTargeting: targeting, idKey: "hb_cache_id")

        var chainedNotifications = adMarkupConsumer
        chainedNotifications = chainNotificationAction(notificationUrl: bid.nurl, onResult: chainedNotifications)
        chainedNotifications = chainNotificationAction(notificationUrl: uuidUrl, onResult: chainedNotifications)
        chainedNotifications = chainNotificationAction(notificationUrl: cacheUrlValue, onResult: chainedNotifications)
        chainedNotifications(bid.adm) // launch chained events
    }

    public static func winNotifierBlock(connection: PrebidServerConnectionProtocol) -> WinNotifierBlock {
        { bid, adMarkupConsumer in
            notifyThroughConnection(connection, winningBid: bid, callback: adMarkupConsumer)
        }
    }

    public static var factoryBlock: WinNotifierFactoryBlock {
        { connection in winNotifierBlock(connection: connection) }
    }

    public static func cacheUrl(fromTargeting targeting: [String: String], idKey: String) -> String? {
        guard let host = targeting["hb_cache_host"],
              let path = targeting["hb_cache_path"],
              let uuid = targeting[idKey] else {
            return nil
        }
        return "https://\(host)\(path)?uuid=\(uuid)"
    }

    // MARK: - Private

    /// Extracts ad markup from a cached response
    /// https://github.com/prebid/prebid-server/blob/994d0f06100f4ef872226112e58e1ad9075cd844/openrtb_ext/bid.go#L133
    /// NOTE: `hb_cache_id` will fetch the entire bid JSON, while `hb_uuid` will fetch just the VAST XML.
    private static func adMarkupString(fromResponse rawResponseString: String) -> String? {
        guard let jsonResponse = try? Functions.dictionary(from: rawResponseString) else {
            return rawResponseString
        }
        return jsonResponse["adm"] as? String
    }
}
