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

class PrebidServerStatusRequester {
    
    var serverEndpoint: String?
    
    init() {
        // Default status endpoint
        if let hostString = try? Host.shared.getHostURL(host: Prebid.shared.prebidServerHost),
           let host = URL(string: hostString)?.host,
           let generatedStatusEndpoint = PathBuilder.buildURL(for: host, path: PBMServerEndpoints.status) {
            
            serverEndpoint = generatedStatusEndpoint
        }
    }
    
    func setCustomStatusEndpoint(_ customStatusEndpoint: String?) {
        if let customStatusEndpoint = customStatusEndpoint {
            
            if customStatusEndpoint.isValidURL() {
                serverEndpoint = customStatusEndpoint
            } else {
                let endpointMessage = serverEndpoint == nil ? "There is no status endpoint to use." : "The '\(serverEndpoint ?? "")' endpoint will be used."
                Log.warn("The provided Prebid Server custom status endpoint is not valid. \(endpointMessage)")
            }
        }
    }
    
    // MARK: - Internal Methods
    
    func requestStatus(_ completion: @escaping PrebidInitializationCallback) {
        guard let serverEndpoint = serverEndpoint else {
            completion(.serverStatusWarning, PBMError.error(description: "Prebid SDK failed to get Prebid Server status endpoint."))
            return
        }
        
        PrebidServerConnection.shared.get(serverEndpoint) { serverResponse in
            guard serverResponse.isOKStatusCode else {
                completion(.serverStatusWarning, serverResponse.error ?? PBMError.error(description: "Error occured during Prebid Server status check."))
                return
            }
            
            completion(.succeeded, nil)
        }
    }
}
