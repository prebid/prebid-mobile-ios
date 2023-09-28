/*   Copyright 2018-2019 Prebid.org, Inc.

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

class NativeRequestTests: XCTestCase {
    
    func testNativeAdUnitCreation() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertNotNil(nativeUnit)
        XCTAssertTrue(nativeUnit.adUnitConfig.configId == Constants.configID1)
    }
    
    func testNativeAdContextType() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertNil(nativeUnit.context)
        nativeUnit.context = ContextType.Social
        XCTAssertNotNil(nativeUnit.context)
        XCTAssertTrue(nativeUnit.context == ContextType.Social)
        nativeUnit.context = ContextType.Product
        XCTAssertTrue(nativeUnit.context == ContextType.Product)
        nativeUnit.context = ContextType.Content
        XCTAssertTrue(nativeUnit.context == ContextType.Content)
        nativeUnit.context = ContextType.Custom
        XCTAssertTrue(nativeUnit.context == ContextType.Custom)
    }
    
    func testNativeAdContextSubType() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertNil(nativeUnit.contextSubType)
        nativeUnit.contextSubType = ContextSubType.General
        XCTAssertNotNil(nativeUnit.contextSubType)
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.General)
        nativeUnit.contextSubType = ContextSubType.Article
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.Article)
        nativeUnit.contextSubType = ContextSubType.Video
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.Video)
        nativeUnit.contextSubType = ContextSubType.Audio
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.Audio)
        nativeUnit.contextSubType = ContextSubType.Image
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.Image)
        nativeUnit.contextSubType = ContextSubType.UserGenerated
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.UserGenerated)
        nativeUnit.contextSubType = ContextSubType.Social
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.Social)
        nativeUnit.contextSubType = ContextSubType.email
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.email)
        nativeUnit.contextSubType = ContextSubType.chatIM
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.chatIM)
        nativeUnit.contextSubType = ContextSubType.SellingProduct
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.SellingProduct)
        nativeUnit.contextSubType = ContextSubType.AppStore
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.AppStore)
        nativeUnit.contextSubType = ContextSubType.ReviewSite
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.ReviewSite)
        nativeUnit.contextSubType = ContextSubType.Custom
        XCTAssertTrue(nativeUnit.contextSubType == ContextSubType.Custom)
    }
    
    func testNativeAdPlacementType() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertNil(nativeUnit.placementType)
        nativeUnit.placementType = PlacementType.FeedContent
        XCTAssertNotNil(nativeUnit.placementType)
        XCTAssertTrue(nativeUnit.placementType == PlacementType.FeedContent)
        nativeUnit.placementType = PlacementType.AtomicContent
        XCTAssertTrue(nativeUnit.placementType == PlacementType.AtomicContent)
        nativeUnit.placementType = PlacementType.OutsideContent
        XCTAssertTrue(nativeUnit.placementType == PlacementType.OutsideContent)
        nativeUnit.placementType = PlacementType.RecommendationWidget
        XCTAssertTrue(nativeUnit.placementType == PlacementType.RecommendationWidget)
        nativeUnit.placementType = PlacementType.Custom
        XCTAssertTrue(nativeUnit.placementType == PlacementType.Custom)
    }
    
    func testNativeAdPlacementCount() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertTrue(nativeUnit.placementCount == 1)
        nativeUnit.placementCount = 123
        XCTAssertTrue(nativeUnit.placementCount == 123)
    }
    
    func testNativeAdSequence() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertTrue(nativeUnit.sequence == 0)
        nativeUnit.sequence = 1
        XCTAssertTrue(nativeUnit.sequence == 1)
    }
    
    func testNativeAdAsseturlSupport() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertTrue(nativeUnit.asseturlsupport == 0)
        nativeUnit.asseturlsupport = 1
        XCTAssertTrue(nativeUnit.asseturlsupport == 1)
    }
    
    func testNativeAdDUrlSupport() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertTrue(nativeUnit.durlsupport == 0)
        nativeUnit.durlsupport = 1
        XCTAssertTrue(nativeUnit.durlsupport == 1)
    }
    
    func testNativeAdPrivacy() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertTrue(nativeUnit.privacy == 0)
        nativeUnit.privacy = 1
        XCTAssertTrue(nativeUnit.privacy == 1)
    }
    
    func testNativeAdExt() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        XCTAssertNil(nativeUnit.ext)
        nativeUnit.ext = ["key": 123]
        XCTAssertNotNil(nativeUnit.ext)
        let ext = ["key" : "value"]
        nativeUnit.ext = ext
        if let data = nativeUnit.ext as? [String : String], let value = data["key"] {
            XCTAssertTrue(value == "value")
        }
    }
    
     func testNativeAdEventTrackers() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        let eventTrackers1 = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])
        let eventTrackers2 = NativeEventTracker(event: EventType.ViewableImpression50, methods: [EventTracking.Custom,EventTracking.Image])
        nativeUnit.eventtrackers = [eventTrackers1, eventTrackers2]
        XCTAssertNotNil(nativeUnit.eventtrackers)
        XCTAssertTrue(nativeUnit.eventtrackers?.count == 2)
        if let eventTrackerArray = nativeUnit.eventtrackers {
            if eventTrackerArray.count == 1 {
                let eventTracker = eventTrackerArray[0]

                XCTAssertTrue(eventTracker.event == EventType.Impression)
                
                let methods = eventTracker.methods
                
                XCTAssertTrue(methods.count == 2)
                XCTAssertTrue(methods[0] == EventTracking.Image)
                XCTAssertTrue(methods[1] == EventTracking.js)
                
            } else if eventTrackerArray.count == 2 {
                let eventTracker = eventTrackerArray[1]
                
                XCTAssertTrue(eventTracker.event == EventType.ViewableImpression50)
                
                let methods = eventTracker.methods
                
                XCTAssertTrue(methods.count == 2)
                XCTAssertTrue(methods[0] == EventTracking.Custom)
                XCTAssertTrue(methods[1] == EventTracking.Image)
                
            }
        }
    }
    
    func testNativeAdAssets() {
        let nativeUnit = NativeRequest(configId: Constants.configID1)
        let assetsTitle = NativeAssetTitle(length:25, required: true)
        let assetsImage = NativeAssetImage(minimumWidth: 20, minimumHeight: 30, required: true)
        nativeUnit.assets = [assetsTitle,assetsImage]
        XCTAssertNotNil(nativeUnit.assets)
        XCTAssertTrue(nativeUnit.assets?.count == 2)
        if let assets = nativeUnit.assets{
            if assets.count > 1 {
                let asset = assets[0]
                if asset.isKind(of: NativeAssetTitle.self)
                {
                    let title = asset as! NativeAssetTitle
                    XCTAssertTrue(title.length == 25)
                }
                if asset.isKind(of: NativeAssetImage.self)
                {
                    let image = asset as! NativeAssetImage
                    XCTAssertTrue(image.widthMin == 20)
                    XCTAssertTrue(image.heightMin == 30)
                }
            }
        }
    }
    
}
