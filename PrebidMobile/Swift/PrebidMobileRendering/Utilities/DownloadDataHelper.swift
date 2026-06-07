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

public typealias PBMDownloadDataCompletionClosure = (Data?, Error?) -> Void

@objc(PBMDownloadDataHelper)
public class DownloadDataHelper: NSObject {

    private weak var serverConnection: PrebidServerConnectionProtocol?

    @objc(initWithServerConnection:)
    public init(serverConnection: PrebidServerConnectionProtocol) {
        self.serverConnection = serverConnection
        super.init()
    }

    @objc(downloadDataForURL:completionClosure:)
    public func downloadData(for url: URL?, completionClosure: @escaping PBMDownloadDataCompletionClosure) {
        serverConnection?.download(url?.absoluteString) { response in
            completionClosure(response.rawData, response.error)
        }
    }

    @objc(downloadDataForURL:maxSize:completionClosure:)
    public func downloadData(for url: URL?, maxSize: Int, completionClosure: @escaping PBMDownloadDataCompletionClosure) {
        serverConnection?.head(url?.absoluteString, timeout: PrebidConstants.FIRE_AND_FORGET_TIMEOUT) { [weak self] response in
            let strContentLength = response.responseHeaders?["Content-Length"]
            var contentLength: Int32 = 0
            let isInteger = strContentLength.map {
                Scanner(string: $0).scanInt32(&contentLength)
            } ?? false

            guard isInteger, contentLength >= 0 else {
                completionClosure(nil, PBMError.error(description: "Unable to determine video file size: \(url?.absoluteString ?? "nil")"))
                return
            }

            guard Int(contentLength) <= maxSize else {
                completionClosure(nil, PBMError.error(description: "Cannot preRender video at \(url?.absoluteString ?? "nil"). Size of \(contentLength) bytes is greater than the maximum size for preloading of \(maxSize) bytes."))
                return
            }

            self?.downloadData(for: url, completionClosure: completionClosure)
        }
    }
}
