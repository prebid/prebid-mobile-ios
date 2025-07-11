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

public typealias PrebidServerResponseCallback = (PrebidServerResponse) -> Void

@objc public protocol PrebidServerConnectionProtocol {
    
    var userAgentService: UserAgentService { get }
    
    func fireAndForget(_ resourceURL: String?)
    func head(_ resourceURL: String?, timeout: TimeInterval, callback: @escaping  PrebidServerResponseCallback)
    func get(_ resourceURL: String?, timeout: TimeInterval, callback: @escaping PrebidServerResponseCallback)
    func post(_ resourceURL: String?, data: Data?, timeout: TimeInterval, callback: @escaping  PrebidServerResponseCallback)
    func post(_ resourceURL: String?, contentType: String?, data: Data?, timeout: TimeInterval, callback: @escaping PrebidServerResponseCallback)
    func download(_ resourceURL: String?, callback: @escaping PrebidServerResponseCallback)
}
