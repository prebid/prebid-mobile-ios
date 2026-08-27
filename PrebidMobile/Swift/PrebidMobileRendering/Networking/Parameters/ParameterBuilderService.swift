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

import CoreTelephony
import Foundation
import MapKit

@objc(PBMParameterBuilderService)
public class ParameterBuilderService: NSObject {

    @objc(buildParamsDictWithAdConfiguration:)
    public static func buildParamsDict(with adConfiguration: AdConfiguration) -> [String: String] {
        buildParamsDict(with: adConfiguration, extraParameterBuilders: nil)
    }

    @objc(buildParamsDictWithAdConfiguration:extraParameterBuilders:)
    public static func buildParamsDict(
        with adConfiguration: AdConfiguration,
        extraParameterBuilders: [ParameterBuilder]?
    ) -> [String: String] {
        buildParamsDict(
            with: adConfiguration,
            bundle: Bundle.main,
            pbmLocationManager: LocationManager.shared,
            pbmDeviceAccessManager: DeviceAccessManager(rootViewController: nil),
            ctTelephonyNetworkInfo: CTTelephonyNetworkInfo(),
            reachability: Reachability.shared,
            sdkConfiguration: Prebid.shared,
            sdkVersion: Functions.sdkVersion,
            targeting: Targeting.shared,
            extraParameterBuilders: extraParameterBuilders
        )
    }

    // Input parameters validation: certain parameter will be validated in particular builder.
    // In such case, even if some parameter is invalid all other builders will work.
    static func buildParamsDict(
        with adConfiguration: AdConfiguration,
        bundle: BundleProtocol,
        pbmLocationManager: LocationManager,
        pbmDeviceAccessManager: DeviceAccessManager,
        ctTelephonyNetworkInfo: CTTelephonyNetworkInfo,
        reachability: Reachability,
        sdkConfiguration: Prebid,
        sdkVersion: String,
        targeting: Targeting,
        extraParameterBuilders: [ParameterBuilder]?
    ) -> [String: String] {
        let bidRequest = createORTBBidRequest(with: targeting)

        var parameterBuilders: [ParameterBuilder] = [
            BasicParameterBuilder(
                adConfiguration: adConfiguration,
                sdkConfiguration: sdkConfiguration,
                sdkVersion: sdkVersion,
                targeting: targeting
            ),
            GeoLocationParameterBuilder(locationManager: pbmLocationManager),
            AppInfoParameterBuilder(bundle: bundle, targeting: targeting),
            DeviceInfoParameterBuilder(deviceAccessManager: pbmDeviceAccessManager),
            NetworkParameterBuilder(
                ctTelephonyNetworkInfo: ctTelephonyNetworkInfo,
                reachability: reachability
            ),
            UserConsentParameterBuilder(),
            SKAdNetworksParameterBuilder(
                bundle: bundle,
                targeting: targeting,
                adConfiguration: adConfiguration
            ),
        ]

        if let extraParameterBuilders = extraParameterBuilders {
            parameterBuilders.append(contentsOf: extraParameterBuilders)
        }

        for builder in parameterBuilders {
            builder.build(bidRequest)
        }

        let ortb = bidRequest.jsonDictionary

        let arbitraryORTB = ArbitraryORTBService.merge(
            sdkORTB: ortb,
            impORTB: adConfiguration.impORTBConfig,
            globalAdUnitORTB: adConfiguration.globalORTBConfig,
            globalORTB: targeting.getGlobalORTBConfig()
        )

        return ORTBParameterBuilder.buildOpenRTB(for: arbitraryORTB)
    }

    static func createORTBBidRequest(with targeting: Targeting) -> ORTBBidRequest {
        let bidRequest = ORTBBidRequest()

        if let userExt = targeting.userExt {
            let existingUserExt = bidRequest.user.ext ?? NSMutableDictionary()
            existingUserExt.addEntries(from: userExt)
            bidRequest.user.ext = existingUserExt
        }

        if let externalUserIds = targeting.getExternalUserIds() {
            bidRequest.user.appendEids(externalUserIds)
        }

        if targeting.sendSharedId {
            bidRequest.user.appendEids([targeting.sharedId.toJSONDictionary()])
        }

        let userKeywords = targeting.getUserKeywords()
        if !userKeywords.isEmpty {
            bidRequest.user.keywords = userKeywords.joined(separator: ",")
        }

        bidRequest.app.storeurl = targeting.storeURL
        bidRequest.app.domain = targeting.domain
        bidRequest.app.bundle = targeting.itunesID

        let appKeywords = targeting.getAppKeywords()
        if !appKeywords.isEmpty {
            bidRequest.app.keywords = appKeywords.joined(separator: ",")
        }

        if let publisherName = targeting.publisherName {
            if bidRequest.app.publisher == nil {
                bidRequest.app.publisher = ORTBPublisher()
            }

            bidRequest.app.publisher?.name = publisherName
        }

        if let coordObj = targeting.coordinate {
            // Rounds with the precision defined in Targeting, or returns the original coordinates if precision is nil.
            let coord2d = Utils.shared.round(
                coordinates: coordObj.mkCoordinateValue,
                precision: Targeting.shared.locationPrecision
            )

            bidRequest.user.geo.lat = NSNumber(value: coord2d.latitude)
            bidRequest.user.geo.lon = NSNumber(value: coord2d.longitude)
        }

        return bidRequest
    }
}
