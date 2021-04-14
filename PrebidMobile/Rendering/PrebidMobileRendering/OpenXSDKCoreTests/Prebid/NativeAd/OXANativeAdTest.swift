//
//  OXANativeAdTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeAdTest: XCTestCase {
    func testInitFromMarkup() {
        let requiredProperties: [(Decoding.PropertyCheck<OXANativeAdMarkup, OXANativeAd>, Error)] = []

        let twoStrings = ["first", "second"]
        
        let titles = twoStrings.map{"\($0) title text"}.map(OXANativeAdMarkupTitle.init).map(OXANativeAdMarkupAsset.init)
        
        let descs = twoStrings.map{"\($0) description"}.map(OXANativeAdMarkupData.init).map(OXANativeAdMarkupAsset.init)
        descs.forEach { $0.data?.dataType = NSNumber(value: OXADataAssetType.desc.rawValue) }
        
        let ctas = twoStrings.map{"\($0) CTA!"}.map(OXANativeAdMarkupData.init).map(OXANativeAdMarkupAsset.init)
        ctas.forEach { $0.data?.dataType = NSNumber(value: OXADataAssetType.ctaText.rawValue) }
        
        let icons = twoStrings.map{"\($0) icon URL"}.map(OXANativeAdMarkupImage.init).map(OXANativeAdMarkupAsset.init)
        icons.forEach { $0.img?.imageType = NSNumber(value: OXAImageAssetType.icon.rawValue) }
        
        let images = twoStrings.map{"\($0) image URL"}.map(OXANativeAdMarkupImage.init).map(OXANativeAdMarkupAsset.init)
        images.forEach { $0.img?.imageType = NSNumber(value: OXAImageAssetType.main.rawValue) }
        
        let videos = twoStrings.map{"\($0) VAST xml"}.map(OXANativeAdMarkupVideo.init).map(OXANativeAdMarkupAsset.init)
        
        func appendAssets<T: OXANativeAdAsset>(adMarkup: OXANativeAdMarkup, assets: [T]) {
            adMarkup.assets = (adMarkup.assets ?? []) + assets.map { x in x.nativeAdMarkupAsset }
        }
        func appendMarkupAssets<T: OXANativeAdMarkupAsset>(_ adMarkup: OXANativeAdMarkup, _ assets: [T]) {
            adMarkup.assets = (adMarkup.assets ?? []) + assets
        }
        
        func testFilterMethods() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<OXANativeAdMarkup, OXANativeAd>] = [
                Decoding.DefaultValuePropertyCheck(value: "0.314",
                                                   writeKeyPath: \.version,
                                                   readKeyPath: \.version,
                                                   defaultValue: ""),
                Decoding.ArrayPropertyCheck(value: try! titles.map(OXANativeAdTitle.init),
                                            writer: appendAssets,
                                            reader: { $0.titles }),
                Decoding.ArrayPropertyCheck(value: try! descs.map(OXANativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects(of: .desc) }),
                Decoding.ArrayPropertyCheck(value: try! ctas.map(OXANativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects(of: .ctaText) }),
                Decoding.ArrayPropertyCheck(value: try! icons.map(OXANativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images(of: .icon) }),
                Decoding.ArrayPropertyCheck(value: try! images.map(OXANativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images(of: .main) }),
                Decoding.ArrayPropertyCheck(value: try! videos.map(OXANativeAdVideo.init),
                                            writer: appendAssets,
                                            reader: { $0.videoAds }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: OXANativeAdMarkup(link: .init(url: "")),
                                                 generator: OXANativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testFilterMethods()
        
        func testBaseArrayMethods() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<OXANativeAdMarkup, OXANativeAd>] = [
                Decoding.DefaultValuePropertyCheck(value: "0.314",
                                                   writeKeyPath: \.version,
                                                   readKeyPath: \.version,
                                                   defaultValue: ""),
                
                Decoding.ArrayPropertyCheck(value: try! titles.map(OXANativeAdTitle.init),
                                            writer: appendAssets,
                                            reader: { $0.titles }),
                Decoding.ArrayPropertyCheck(value: try! (descs + ctas).map(OXANativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects }),
                Decoding.ArrayPropertyCheck(value: try! (icons + images).map(OXANativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images }),
                Decoding.ArrayPropertyCheck(value: try! videos.map(OXANativeAdVideo.init),
                                            writer: appendAssets,
                                            reader: { $0.videoAds }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: OXANativeAdMarkup(link: .init(url: "")),
                                                 generator: OXANativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testBaseArrayMethods()
        
        func testConvenienceGetters() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<OXANativeAdMarkup, OXANativeAd>] = [
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
                Decoding.DefaultValuePropertyCheck(value: try! OXANativeAdVideo(nativeAdMarkupAsset: videos[0]),
                                                   defaultValue: nil,
                                                   writer: { markup, str in appendMarkupAssets(markup, videos) },
                                                   reader: { $0.videoAd }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: OXANativeAdMarkup(link: .init(url: "")),
                                                 generator: OXANativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testConvenienceGetters()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(OXANativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))), NSObject())
        XCTAssertEqual(OXANativeAd(nativeAdMarkup: .init(link: .init())),
                       OXANativeAd(nativeAdMarkup: .init(link: .init())))
        XCTAssertEqual(OXANativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))),
                       OXANativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))))
        XCTAssertEqual(OXANativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))),
                       OXANativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))))
        XCTAssertNotEqual(OXANativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))),
                          OXANativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))))
    }
    
    func testMeassurementSession() {
        let application = MockUIApplication()
        let connection = MockServerConnection()
        let sdkConfiguration = OXASDKConfiguration()
        
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
        
        let nativeMarkup = OXANativeAdMarkup(link: .init(url: ""))
        nativeMarkup.eventtrackers = [OXANativeAdMarkupEventTracker(event: .OMID,
                                                           method: .JS,
                                                           url: .init(""))]
        
        var nativeAd: OXANativeAd? = OXANativeAd(nativeAdMarkup: nativeMarkup,
                                                 application: application,
                                                 measurementWrapper: measurement,
                                                 serverConnection: connection,
                                                 sdkConfiguration: sdkConfiguration)
        
        nativeAd?.register(UIView(), clickableViews: nil)
        
        wait(for: measurementExpectations, timeout: 5, enforceOrder: true)
        
        nativeAd = nil
        
        wait(for: [expectationSessionStop], timeout: 2);
    }
    
    func testMeassurementSessionWithoutTracker() {
        let application = MockUIApplication()
        let connection = MockServerConnection()
        let sdkConfiguration = OXASDKConfiguration()
        
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
        let nativeMarkup = OXANativeAdMarkup(link: .init(url: ""))
        let nativeAd = OXANativeAd(nativeAdMarkup: nativeMarkup,
                                   application: application,
                                   measurementWrapper: measurement,
                                   serverConnection: connection,
                                   sdkConfiguration: sdkConfiguration)
        
        nativeAd.register(UIView(), clickableViews: nil)
        
        wait(for: [expectationInitializeSession], timeout: 2);
    }
}
