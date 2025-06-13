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

@testable @_spi(PBMInternal) import PrebidMobile


// DESCRIPTION
// We can't test all flow for MRAID.close() because of iOS viewController on pop.
// Using it from unit tests does not allow to call modalManagerDidFinishPop from the completion of dismissViewControllerAnimated. So this test case is divided into two parts:
// - tests the MRAID.close() leads to popModal (withMocked modal manager)
// - tests that modalManagerDidFinishPop leads to creativeReadyToReimplant and default MRAID state (with non mocked modal manager)
class PBMHTMLCreativeTest_MRAIDClose: XCTestCase, CreativeViewDelegate {
  
    var creativeReadyToReimplantExpectation: XCTestExpectation!

    func testCloseReadyToReimplant() {
        
        // SETUP ENVIRONMENT
        
        let mockWebView = MockPBMWebView();
        mockWebView.isViewable = true

        let adConfiguration = AdConfiguration()
        adConfiguration.isInterstitialAd = true
        
        let model = CreativeModel(adConfiguration: adConfiguration)
        model.html = "<html>test html</html>"
        
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        transaction.adConfiguration.isInterstitialAd = true
        
        let htmlCreative =  PBMHTMLCreative(
            creativeModel: model,
            transaction: transaction,
            webView: mockWebView,
               sdkConfiguration: Prebid.mock
        )
        
        let popModalExpectation = self.expectation(description: "Should pop modal")
        let modalManager = MockModalManager()
        modalManager.mock_popModalClosure = {
            popModalExpectation.fulfill()
        }
        
        htmlCreative.modalManager = modalManager
        htmlCreative.creativeViewDelegate = self
        
        let mockVC = MockViewController()
        
        htmlCreative.setupView()
        htmlCreative.showAsInterstitial(fromRootViewController: mockVC, displayProperties: InterstitialDisplayProperties())

        // RUN TEST
        
        htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("close"))

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCloseChangeState() {
        
        // SETUP ENVIRONMENT
        
        let mockWebView = MockPBMWebView();
        mockWebView.isViewable = true
        
        let model = CreativeModel(adConfiguration:AdConfiguration())
        model.html = "<html>test html</html>"

        let htmlCreative =  PBMHTMLCreative(
            creativeModel: model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: mockWebView,
               sdkConfiguration: Prebid.mock
        )
        
        htmlCreative.modalManager = ModalManager()
        htmlCreative.creativeViewDelegate = self
        
        let mockVC = MockViewController()
        let state = Factory.createModalState(view: mockWebView,
                                             adConfiguration:AdConfiguration(),
                                             displayProperties:InterstitialDisplayProperties())
        htmlCreative.modalManager!.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:nil)
        
        htmlCreative.setupView()
        
        // SETUP EXPECTATIONS
        
        creativeReadyToReimplantExpectation = self.expectation(description: "Should set creative ready to reimplant")
        
        let changeToMRAIDExpectation = self.expectation(description: "Should change to default MRAID state")
        mockWebView.mock_changeToMRAIDState = { (state) in
            changeToMRAIDExpectation.fulfill()
            PBMAssertEq(state, .default)
        }
        
        // RUN TEST
        
        htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("close"))
        htmlCreative.modalManagerDidFinishPop(state)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: CreativeViewDelegate
    
    func creativeDidComplete(_ creative: AbstractCreative) {}
    func videoCreativeDidComplete(_ creative: AbstractCreative) {}
    func creativeDidDisplay(_ creative: AbstractCreative) {}
    func creativeWasClicked(_ creative: AbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {}
    
    func creativeReadyToReimplant(_ creative: AbstractCreative) {
        creativeReadyToReimplantExpectation.fulfill()
    }
    
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
}
