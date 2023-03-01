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

import XCTest

@testable import PrebidMobile

class PBMHTMLCreativeTest_ModalManagerDelegate: PBMHTMLCreativeTest_Base {
    
    func testInterstitialDidLeaveApp() {
        var called = false
        self.creativeInterstitialDidLeaveAppHandler = { (creative) in
            PBMAssertEq(creative, self.htmlCreative)
            called = true
        }
        
        let state = PBMModalState(view: PBMWebView(), adConfiguration:AdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.htmlCreative.modalManagerDidFinishPop(poppedState!)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.htmlCreative.modalManagerDidLeaveApp(leavingState!)
            
        })
        self.htmlCreative.modalManagerDidLeaveApp(state)
        
        XCTAssert(called)
    }
    
    func testInterstitialAdClosed() {
        var called = false
        self.creativeInterstitialDidCloseHandler = { (creative) in
            PBMAssertEq(creative, self.htmlCreative)
            called = true
        }
        
        htmlCreative.setupView()
        
        let state = PBMModalState(view: PBMWebView(), adConfiguration:AdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.htmlCreative.modalManagerDidFinishPop(poppedState!)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.htmlCreative.modalManagerDidLeaveApp(leavingState!)
            
        })
        
        htmlCreative.modalManagerDidFinishPop(state)
        
        XCTAssert(called)
    }
    
    func testInterstitialAdClosed_clickthroughOpened() {
        var called = false
        self.creativeInterstitialDidCloseHandler = { (creative) in
            PBMAssertEq(creative, self.htmlCreative)
            called = true
        }
        
        htmlCreative.clickthroughVisible = true
        htmlCreative.setupView()
        
        let state = PBMModalState(view: PBMWebView(), adConfiguration:AdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: { [weak self] poppedState in
            self?.htmlCreative.modalManagerDidFinishPop(poppedState!)
        }, onStateHasLeftApp: { [weak self] leavingState in
            self?.htmlCreative.modalManagerDidLeaveApp(leavingState!)
            
        })
        
        htmlCreative.modalManagerDidFinishPop(state)
        htmlCreative.modalManagerDidFinishPop(state)
        
        XCTAssert(called)
    }
}
