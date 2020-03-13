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


public class BannerBaseAdUnit: AdUnit {

    public var parameters: Parameters?

    //MARK: - Parameters class
    
    /// Describes an [OpenRTB](https://www.iab.com/wp-content/uploads/2016/03/OpenRTB-API-Specification-Version-2-5-FINAL.pdf) video object
    @objc(BannerAdUnitParameters)
    public class Parameters: NSObject {

        /**
        List of supported API frameworks for this impression. If an API is not explicitly listed, it is assumed not to be supported.
        # Example #
        ```
        | Value | Description |
        |-------|-------------|
        | 1     | VPAID 1.0   |
        | 2     | VPAID 2.0   |
        | 3     | VPAID 2.0   |
        | 4     | ORMMA       |
        | 5     | MRAID-2     |
        | 6     | MRAID-3     |
        ```
        */
        @objc
        public var api: [Int]?

    }
}
