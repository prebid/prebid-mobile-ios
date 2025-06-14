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

@testable @_spi(PBMInternal) import PrebidMobile

class VideoFileTypeTest : XCTestCase, CreativeViewDelegate, PBMVideoViewDelegate {
    
    let viewController = MockViewController()
    var pbmVideoCreative:PBMVideoCreative!
    var expectationVideoDidComplete:XCTestExpectation!
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationCreativeDidDisplay:XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        
        Prebid.reset()
        
        super.tearDown()
    }
    
    func testTypes() {
        Prebid.forcedIsViewable = true
        defer { Prebid.reset() }

        self.continueAfterFailure = true
        
        let typesToTest: [(MockServerMimeType, String)] = [
            (.MP4, "small.mp4"),
            (.MOV, "small.mov"),
            (.M4V, "small.m4v"),
            (.XM4V, "small.m4v")
        ]
        
        for (mimeType, fileName) in typesToTest {
            
            for view in self.viewController.view.subviews {
                view.removeFromSuperview()
            }
            
            self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
            self.expectationVideoDidComplete = self.expectation(description: "expectationVideoDidComplete")
            self.expectationCreativeDidDisplay = self.expectation(description: "expectationCreativeDidDisplay")
            
            //Change the inline response to claim that it will respond with m4v
            var inlineResponse = UtilitiesForTesting.loadFileAsStringFromBundle("document_with_one_inline_ad.xml")!
            let needle = MockServerMimeType.MP4.rawValue
            let replaceWith = mimeType.rawValue
            inlineResponse = inlineResponse.PBMstringByReplacingRegex(needle, replaceWith:replaceWith)
            
            //Make an PrebidServerConnection and redirect its network requests to the Mock Server
            let connection = UtilitiesForTesting.createConnectionForMockedTest()
            
            //Rule for VAST
            let ruleVAST =  MockServerRule(urlNeedle: "foo.com/inline", mimeType:  MockServerMimeType.XML.rawValue, connectionID: connection.internalID, strResponse: inlineResponse)
            
            //Add a rule for video File
            let ruleVideo = MockServerRule(urlNeedle: "http://get_video_file", mimeType: mimeType.rawValue, connectionID: connection.internalID, fileName: fileName)
            MockServer.shared.resetRules([ruleVAST, ruleVideo])
            
            //Create adConfiguration
            let adConfiguration = AdConfiguration()
            adConfiguration.adFormats = [.video]
            adConfiguration.winningBidAdFormat = .video
//            adConfiguration.domain = "foo.com/inline"
            
            //Create CreativeModel
            let creativeModel = CreativeModel(adConfiguration:adConfiguration)
            creativeModel.videoFileURL = "http://get_video_file"
            
            let transaction = UtilitiesForTesting.createEmptyTransaction()
            transaction.creativeModels = [creativeModel]

            //Get a Creative
            let creativeFactory = PBMCreativeFactory(serverConnection:connection, transaction: transaction, finishedCallback: { creativesArray, error in
                
                    if (error != nil) {
                        XCTFail("error: \(error?.localizedDescription ?? "")")
                    }
                    
                    self.expectationDownloadCompleted.fulfill()
                    
                    guard let pbmVideoCreative = creativesArray?.first as? PBMVideoCreative else {
                        XCTFail("Could not cast creative as PBMVideoCreative")
                        return
                    }
                    
                    pbmVideoCreative.creativeViewDelegate = self
                    pbmVideoCreative.videoView.videoViewDelegate = self
                    self.pbmVideoCreative = pbmVideoCreative
                    
                    DispatchQueue.main.async {
                        self.pbmVideoCreative.display(rootViewController: self.viewController)
                    }
                }
            )
            
            DispatchQueue.global().async {
                creativeFactory.start()
            }
            
            self.waitForExpectations(timeout: 10, handler:nil)
        }
    }
    
    
    //MARK: - CreativeViewDelegate
    func creativeDidComplete(_ creative: AbstractCreative) {}
    func videoCreativeDidComplete(_ creative: AbstractCreative) {}
    func creativeWasClicked(_ creative: AbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeReadyToReimplant(_ creative: AbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {}
    
    func creativeDidDisplay(_ creative: AbstractCreative) {
        self.expectationCreativeDidDisplay.fulfill()
    }
    
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
    
    // MARK: - PBMVideoViewDelegate
    
    func videoViewFailedWithError(_ error: Error) {}
    func videoViewReadyToDisplay() {}
    
    func videoViewCompletedDisplay() {
        self.expectationVideoDidComplete.fulfill()
    }
    
    func videoWasClicked() {}
    func videoViewCurrentPlayingTime(_ currentPlayingTime: NSNumber) {}
}
