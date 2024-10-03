/*   Copyright 2018-2021 Prebid.org, Inc.

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

/// Represents the configuration for a native ad, including markup and version information.
@objc(PBMNativeAdConfiguration) @objcMembers
public class NativeAdConfiguration: NSObject {
    
    /// Version of the Native Markup version in use.
    public var version: String = "1.2"
    
    /// The object containing the request details for the native markup.
    public var markupRequestObject = NativeMarkupRequestObject()
    
    /// Initializes a new instance of `NativeAdMarkup` with default values.
    public override init() {
        super.init()
    }
    
    /// Initializes a new instance of `NativeAdConfiguration` with the specified native parameters.
    /// - Parameter nativeParameters: The parameters to configure the native ad.
    init(nativeParameters: NativeParameters) {
        version = nativeParameters.version
        markupRequestObject = NativeMarkupRequestObject(nativeParameters: nativeParameters)
        
        super.init()
    }
}
