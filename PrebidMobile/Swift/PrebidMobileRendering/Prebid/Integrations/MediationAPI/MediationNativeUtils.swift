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

@objc(PBMMediationNativeUtils) @objcMembers
public class MediationNativeUtils: NSObject {
    public static func findNative(in extras: [AnyHashable: Any]) -> Result<NativeAd, Error> {
        guard let response = extras[PBMMediationAdNativeResponseKey] as? [String: AnyObject] else {
            let error = PBMError.error(description: "The bid response dictionary is absent in the extras")
            return .failure(error)
        }
        
        guard let cacheId = response[PrebidLocalCacheIdKey] as? String else {
            let error = PBMError.error(description: "No cache id in bid response dictionary")
            return .failure(error)
        }
        
        guard let nativeAd = NativeAd.create(cacheId: cacheId) else {
            let error = PBMError.error(description: "No cached native ad")
            return .failure(error)
        }
        
        return .success(nativeAd)
    }
}
