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

class NativeAdTest: XCTestCase {
    
    func testInitFromMarkup() {
        let requiredProperties: [(Decoding.PropertyCheck<PBMNativeAdMarkup, PBRNativeAd>, Error)] = []
        
        let twoStrings = ["first", "second"]
        
        let titles = twoStrings.map{"\($0) title text"}.map(PBMNativeAdMarkupTitle.init).map(PBMNativeAdMarkupAsset.init)
        
        let descs = twoStrings.map{"\($0) description"}.map(PBMNativeAdMarkupData.init).map(PBMNativeAdMarkupAsset.init)
        descs.forEach { $0.data?.dataType = NSNumber(value: NativeDataAssetType.desc.rawValue) }
        
        let ctas = twoStrings.map{"\($0) CTA!"}.map(PBMNativeAdMarkupData.init).map(PBMNativeAdMarkupAsset.init)
        ctas.forEach { $0.data?.dataType = NSNumber(value: NativeDataAssetType.ctaText.rawValue) }
        
        let icons = twoStrings.map{"\($0) icon URL"}.map(PBMNativeAdMarkupImage.init).map(PBMNativeAdMarkupAsset.init)
        icons.forEach { $0.img?.imageType = NSNumber(value: NativeImageAssetType.icon.rawValue) }
        
        let images = twoStrings.map{"\($0) image URL"}.map(PBMNativeAdMarkupImage.init).map(PBMNativeAdMarkupAsset.init)
        images.forEach { $0.img?.imageType = NSNumber(value: NativeImageAssetType.main.rawValue) }
        
        let videos = twoStrings.map{"\($0) VAST xml"}.map(PBMNativeAdMarkupVideo.init).map(PBMNativeAdMarkupAsset.init)
        
        func appendAssets<T: NativeAdAsset>(adMarkup: PBMNativeAdMarkup, assets: [T]) {
            adMarkup.assets = (adMarkup.assets ?? []) + assets.map { x in x.nativeAdMarkupAsset }
        }
        func appendMarkupAssets<T: PBMNativeAdMarkupAsset>(_ adMarkup: PBMNativeAdMarkup, _ assets: [T]) {
            adMarkup.assets = (adMarkup.assets ?? []) + assets
        }
        
        func testFilterMethods() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkup, PBRNativeAd>] = [
                Decoding.DefaultValuePropertyCheck(value: "0.314",
                                                   writeKeyPath: \.version,
                                                   readKeyPath: \.version,
                                                   defaultValue: ""),
                Decoding.ArrayPropertyCheck(value: try! titles.map(NativeAdTitle.init),
                                            writer: appendAssets,
                                            reader: { $0.titles }),
                Decoding.ArrayPropertyCheck(value: try! descs.map(NativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects(of: .desc) }),
                Decoding.ArrayPropertyCheck(value: try! ctas.map(NativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects(of: .ctaText) }),
                Decoding.ArrayPropertyCheck(value: try! icons.map(NativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images(of: .icon) }),
                Decoding.ArrayPropertyCheck(value: try! images.map(NativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images(of: .main) }),
                Decoding.ArrayPropertyCheck(value: try! videos.map(NativeAdVideo.init),
                                            writer: appendAssets,
                                            reader: { $0.videoAds }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: PBMNativeAdMarkup(link: .init(url: "")),
                                                 generator: PBRNativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testFilterMethods()
        
        func testBaseArrayMethods() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkup, PBRNativeAd>] = [
                Decoding.DefaultValuePropertyCheck(value: "0.314",
                                                   writeKeyPath: \.version,
                                                   readKeyPath: \.version,
                                                   defaultValue: ""),
                
                Decoding.ArrayPropertyCheck(value: try! titles.map(NativeAdTitle.init),
                                            writer: appendAssets,
                                            reader: { $0.titles }),
                Decoding.ArrayPropertyCheck(value: try! (descs + ctas).map(NativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects }),
                Decoding.ArrayPropertyCheck(value: try! (icons + images).map(NativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images }),
                Decoding.ArrayPropertyCheck(value: try! videos.map(NativeAdVideo.init),
                                            writer: appendAssets,
                                            reader: { $0.videoAds }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: PBMNativeAdMarkup(link: .init(url: "")),
                                                 generator: PBRNativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testBaseArrayMethods()
        
        func testConvenienceGetters() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkup, PBRNativeAd>] = [
                Decoding.DefaultValuePropertyCheck(value: "0.314",
                                                   writeKeyPath: \.version,
                                                   readKeyPath: \.version,
                                                   defaultValue: ""),
                
                Decoding.DefaultValuePropertyCheck(value: titles[0].title!.text,
                                                   defaultValue: "",
                                                   writer: { markup, str in appendMarkupAssets(markup, titles) },
                                                   reader: { $0.title }),
                Decoding.DefaultValuePropertyCheck(value: descs[0].data!.value,
                                                   defaultValue: "",
                                                   writer: { markup, str in appendMarkupAssets(markup, descs) },
                                                   reader: { $0.text }),
                Decoding.DefaultValuePropertyCheck(value: ctas[0].data!.value,
                                                   defaultValue: "",
                                                   writer: { markup, str in appendMarkupAssets(markup, ctas) },
                                                   reader: { $0.callToAction }),
                Decoding.DefaultValuePropertyCheck(value: icons[0].img!.url,
                                                   defaultValue: "",
                                                   writer: { markup, str in appendMarkupAssets(markup, icons) },
                                                   reader: { $0.iconURL }),
                Decoding.DefaultValuePropertyCheck(value: images[0].img!.url,
                                                   defaultValue: "",
                                                   writer: { markup, str in appendMarkupAssets(markup, images) },
                                                   reader: { $0.imageURL }),
                Decoding.DefaultValuePropertyCheck(value: try! NativeAdVideo(nativeAdMarkupAsset: videos[0]),
                                                   defaultValue: nil,
                                                   writer: { markup, str in appendMarkupAssets(markup, videos) },
                                                   reader: { $0.videoAd }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: PBMNativeAdMarkup(link: .init(url: "")),
                                                 generator: PBRNativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testConvenienceGetters()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(PBRNativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))), NSObject())
        XCTAssertEqual(PBRNativeAd(nativeAdMarkup: .init(link: .init())),
                       PBRNativeAd(nativeAdMarkup: .init(link: .init())))
        XCTAssertEqual(PBRNativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))),
                       PBRNativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))))
        XCTAssertEqual(PBRNativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))),
                       PBRNativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))))
        XCTAssertNotEqual(PBRNativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))),
                          PBRNativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))))
    }
    
    func testMeassurementSession() {
        let application = MockUIApplication()
        let connection = MockServerConnection()
        let sdkConfiguration = PrebidRenderingConfig.mock
        
        let measurement = MockMeasurementWrapper()
        
        let expectationInitializeSession = self.expectation(description:"expectationInitializeSession")
        let expectationSessionStart = self.expectation(description:"expectationSessionStart")
        let expectationSessionStop = self.expectation(description:"expectationSessionStop")
        
        measurement.initializeSessionClosure = { session in
            guard let session = session as? MockMeasurementSession else {
                XCTFail()
                return
            }
            
            session.startClosure = {
                expectationSessionStart.fulfill()
            }
            
            session.stopClosure = {
                expectationSessionStop.fulfill()
            }
            
            expectationInitializeSession.fulfill()
        }
        
        let measurementExpectations = [
            expectationInitializeSession,
            expectationSessionStart,
        ]
        
        let nativeMarkup = PBMNativeAdMarkup(link: .init(url: ""))
        nativeMarkup.eventtrackers = [PBMNativeAdMarkupEventTracker(event: NativeEventType.omid.rawValue,
                                                                    method: NativeEventTrackingMethod.js.rawValue,
                                                                    url: .init(""))]
        
        var nativeAd: PBRNativeAd? = PBRNativeAd(nativeAdMarkup: nativeMarkup,
                                           application: application,
                                           measurementWrapper: measurement,
                                           serverConnection: connection,
                                           sdkConfiguration: sdkConfiguration)
        
        nativeAd?.registerView(UIView(), clickableViews: nil)
        
        wait(for: measurementExpectations, timeout: 5, enforceOrder: true)
        
        nativeAd = nil
        
        wait(for: [expectationSessionStop], timeout: 2);
    }
    
    func testMeassurementSessionWithoutTracker() {
        let application = MockUIApplication()
        let connection = MockServerConnection()
        let sdkConfiguration = PrebidRenderingConfig.mock
        
        let measurement = MockMeasurementWrapper()
        
        let expectationInitializeSession = self.expectation(description:"expectationInitializeSession")
        expectationInitializeSession.isInverted = true
        
        measurement.initializeSessionClosure = { session in
            guard let _ = session as? MockMeasurementSession else {
                XCTFail()
                return
            }
            
            expectationInitializeSession.fulfill()
        }
        
        //Without an OMID event tracker a session should not be created
        let nativeMarkup = PBMNativeAdMarkup(link: .init(url: ""))
        let nativeAd = PBRNativeAd(nativeAdMarkup: nativeMarkup,
                                application: application,
                                measurementWrapper: measurement,
                                serverConnection: connection,
                                sdkConfiguration: sdkConfiguration)
        
        nativeAd.registerView(UIView(), clickableViews: nil)
        
        wait(for: [expectationInitializeSession], timeout: 2);
    }
}
