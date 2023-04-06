/*   Copyright 2018-2019 Prebid.org, Inc.
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

@objc public protocol BannerBasedAdUnitProtocol {
    var bannerParameters: BannerParameters { get set }
}

@available(*, deprecated, message: "This class is deprecated.")
public class BannerBaseAdUnit: AdUnit {

    @available(*, deprecated, message: "This property is deprecated. Please, use bannerParameters instead.")
    public var parameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
        set { adUnitConfig.adConfiguration.bannerParameters = newValue }
    }
    
    @available(*, deprecated, message: "This class is deprecated. Please, use BannerParameters instead.")
    @objc(PBBannerAdUnitParameters)
    public class Parameters: NSObject {

        /// List of supported API frameworks for this impression. If an API is not explicitly listed, it is assumed not to be supported.
        @objc
        public var api: [Signals.Api]?
    }
}
