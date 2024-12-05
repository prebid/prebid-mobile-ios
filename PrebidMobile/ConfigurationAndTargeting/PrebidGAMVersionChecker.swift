/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

class PrebidGAMVersionChecker {
    
    var latestTestedGMAVersion: (Int, Int, Int) {
        (11, 13, 0)
    }
    
    var currentGMAVersion: (Int, Int, Int)?
    
    func checkGMAVersionDeprecated(_ sdkVersion: String) {
        verifyGMAVersion(sdkVersion: extractSDKVersion(sdkVersion))
    }
    
    func checkGMAVersion(_ sdkVersion: String) {
        verifyGMAVersion(sdkVersion: extractVersionNumber(sdkVersion))
    }
    
    // For deprecated `sdkVersion` - afma-sdk-i-v10.8.0
    private func extractSDKVersion(_ sdkVersionString: String) -> (Int, Int, Int)? {
        guard let vIndex = sdkVersionString.lastIndex(of: "v") else {
            Log.error("Error occured during GMA SDK version parsing.")
            return nil
        }
        
        let versionStartIndex = sdkVersionString.index(after: vIndex)
        let versionString = String(sdkVersionString[versionStartIndex..<sdkVersionString.endIndex])
        
        return extractVersionNumber(versionString)
    }
    
    // For `versionNumber` string - 10.8.0
    private func extractVersionNumber(_ versionString: String) -> (Int, Int, Int)? {
        let sdkVersionIntegers = versionString
            .split(separator: ".")
            .compactMap { Int($0) }
        
        guard sdkVersionIntegers.count == 3 else {
            Log.error("Error occured during GMA SDK version parsing.")
            return nil
        }
        
        return (sdkVersionIntegers[0], sdkVersionIntegers[1], sdkVersionIntegers[2])
    }
    
    private func verifyGMAVersion(sdkVersion: (Int, Int, Int)?) {
        self.currentGMAVersion = sdkVersion
        
        guard let currentGAMVersion = currentGMAVersion else {
            return
        }
        
        if latestTestedGMAVersion.0 < currentGAMVersion.0 ||
            latestTestedGMAVersion.1 < currentGAMVersion.1 ||
            latestTestedGMAVersion.2 < currentGAMVersion.2 {
            Log.warn("The current version of Prebid SDK is not validated with the latest version of GMA SDK. Please update the Prebid SDK or post a ticket on the github.")
        }
    }
}
