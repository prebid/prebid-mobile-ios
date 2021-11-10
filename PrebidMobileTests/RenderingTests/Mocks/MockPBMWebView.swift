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

@testable import PrebidMobile

typealias MockMRAIDResizeHandler = (MRAIDResizeProperties?) -> Void
typealias MockMRAIDExpandHandler = (MRAIDExpandProperties?) -> Void

class MockPBMWebView: PBMWebView {
    
    var mock_loadHTML: ((String, URL?, Bool) -> Void)?
    override func loadHTML(_ html: String, baseURL: URL?, injectMraidJs: Bool) {
        self.mock_loadHTML?(html, baseURL, injectMraidJs)
    }
    
    var mock_changeToMRAIDState: ((PBMMRAIDState) -> Void)?
    override func changeToMRAIDState(_ state: PBMMRAIDState) {
        self.mock_changeToMRAIDState?(state)
    }
    
    override func prepareForMRAID(withRootViewController: UIViewController) {
        self.isViewable = true
    }
    
    var mock_PBMAddCropAndCenterConstraints: ((CGFloat, CGFloat) -> Void)?
    override func PBMAddCropAndCenterConstraints(initialWidth: CGFloat, initialHeight: CGFloat) {
        self.mock_PBMAddCropAndCenterConstraints?(initialWidth, initialHeight)
    }
    
    var mock_MRAID_error: ((String, PBMMRAIDAction) -> Void)?
    override func MRAID_error(_ message: String, action: PBMMRAIDAction) {
        self.mock_MRAID_error?(message, action)
    }
    
    var mock_MRAID_getResizeProperties: ((MockMRAIDResizeHandler) -> Void)?
    override func MRAID_getResizeProperties(completionHandler: @escaping MockMRAIDResizeHandler) {
        self.mock_MRAID_getResizeProperties?(completionHandler)
    }
    
    var mock_MRAID_getExpandProperties: ((MockMRAIDExpandHandler) -> Void)?
    override func MRAID_getExpandProperties(completionHandler: @escaping MockMRAIDExpandHandler) {
        self.mock_MRAID_getExpandProperties?(completionHandler)
    }
    
}
