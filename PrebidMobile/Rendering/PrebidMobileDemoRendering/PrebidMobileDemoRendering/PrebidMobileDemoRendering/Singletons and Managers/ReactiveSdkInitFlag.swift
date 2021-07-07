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

class ReactiveSdkInitFlag {
    private(set) var sdkInitialized = false
    private var onSdkInitializedBlock: (() -> ())?
    
    func onSdkInitialized(perform block: @escaping () -> ()) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            if self.sdkInitialized {
                block()
            } else {
                let oldBlock = self.onSdkInitializedBlock
                self.onSdkInitializedBlock = {
                    oldBlock?()
                    block()
                }
            }
        }
    }
    
    func markSdkInitialized() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.sdkInitialized else {
                return
            }
            self.sdkInitialized = true
            let block = self.onSdkInitializedBlock
            self.onSdkInitializedBlock = nil
            block?()
        }
    }
}
