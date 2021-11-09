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
import XCTest

// Use this class when need to test behavior in the global thread from the main thread.
final class MockNSThread : PBMNSThreadProtocol {
    
    var mockIsMainThread: Bool
    
    init(mockIsMainThread: Bool) {
        self.mockIsMainThread = mockIsMainThread
    }
    
    // MARK: - PBMNSThreadProtocol
    
    var isMainThread: Bool {
        return mockIsMainThread
    }
}

// Use this class when need to test switching the execution from the global threat to the main thread.
final class PBMThread : PBMNSThreadProtocol {
    
    var checkThreadCallback:((Bool) -> Void)
    
    init(checkThreadCallback: @escaping ((Bool) -> Void)) {
        self.checkThreadCallback = checkThreadCallback
    }
    
    // MARK: - PBMNSThreadProtocol
    
    var isMainThread: Bool {
        let isMainThread = Thread.isMainThread
        
        checkThreadCallback(isMainThread)
        
        return isMainThread
    }
}
