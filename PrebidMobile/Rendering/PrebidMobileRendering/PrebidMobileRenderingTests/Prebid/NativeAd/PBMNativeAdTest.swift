//
//  PBMNativeAdTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeAdTest: XCTestCase {
    func testInitFromMarkup() {
        let requiredProperties: [(Decoding.PropertyCheck<PBMNativeAdMarkup, PBMNativeAd>, Error)] = []

        let twoStrings = ["first", "second"]
        
        let titles = twoStrings.map{"\($0) title text"}.map(PBMNativeAdMarkupTitle.init).map(PBMNativeAdMarkupAsset.init)
        
        let descs = twoStrings.map{"\($0) description"}.map(PBMNativeAdMarkupData.init).map(PBMNativeAdMarkupAsset.init)
        descs.forEach { $0.data?.dataType = NSNumber(value: PBMDataAssetType.desc.rawValue) }
        
        let ctas = twoStrings.map{"\($0) CTA!"}.map(PBMNativeAdMarkupData.init).map(PBMNativeAdMarkupAsset.init)
        ctas.forEach { $0.data?.dataType = NSNumber(value: PBMDataAssetType.ctaText.rawValue) }
        
        let icons = twoStrings.map{"\($0) icon URL"}.map(PBMNativeAdMarkupImage.init).map(PBMNativeAdMarkupAsset.init)
        icons.forEach { $0.img?.imageType = NSNumber(value: PBMImageAssetType.icon.rawValue) }
        
        let images = twoStrings.map{"\($0) image URL"}.map(PBMNativeAdMarkupImage.init).map(PBMNativeAdMarkupAsset.init)
        images.forEach { $0.img?.imageType = NSNumber(value: PBMImageAssetType.main.rawValue) }
        
        let videos = twoStrings.map{"\($0) VAST xml"}.map(PBMNativeAdMarkupVideo.init).map(PBMNativeAdMarkupAsset.init)
        
        func appendAssets<T: PBMNativeAdAsset>(adMarkup: PBMNativeAdMarkup, assets: [T]) {
            adMarkup.assets = (adMarkup.assets ?? []) + assets.map { x in x.nativeAdMarkupAsset }
        }
        func appendMarkupAssets<T: PBMNativeAdMarkupAsset>(_ adMarkup: PBMNativeAdMarkup, _ assets: [T]) {
            adMarkup.assets = (adMarkup.assets ?? []) + assets
        }
        
        func testFilterMethods() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkup, PBMNativeAd>] = [
                Decoding.DefaultValuePropertyCheck(value: "0.314",
                                                   writeKeyPath: \.version,
                                                   readKeyPath: \.version,
                                                   defaultValue: ""),
                Decoding.ArrayPropertyCheck(value: try! titles.map(PBMNativeAdTitle.init),
                                            writer: appendAssets,
                                            reader: { $0.titles }),
                Decoding.ArrayPropertyCheck(value: try! descs.map(PBMNativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects(of: .desc) }),
                Decoding.ArrayPropertyCheck(value: try! ctas.map(PBMNativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects(of: .ctaText) }),
                Decoding.ArrayPropertyCheck(value: try! icons.map(PBMNativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images(of: .icon) }),
                Decoding.ArrayPropertyCheck(value: try! images.map(PBMNativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images(of: .main) }),
                Decoding.ArrayPropertyCheck(value: try! videos.map(PBMNativeAdVideo.init),
                                            writer: appendAssets,
                                            reader: { $0.videoAds }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: PBMNativeAdMarkup(link: .init(url: "")),
                                                 generator: PBMNativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testFilterMethods()
        
        func testBaseArrayMethods() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkup, PBMNativeAd>] = [
                Decoding.DefaultValuePropertyCheck(value: "0.314",
                                                   writeKeyPath: \.version,
                                                   readKeyPath: \.version,
                                                   defaultValue: ""),
                
                Decoding.ArrayPropertyCheck(value: try! titles.map(PBMNativeAdTitle.init),
                                            writer: appendAssets,
                                            reader: { $0.titles }),
                Decoding.ArrayPropertyCheck(value: try! (descs + ctas).map(PBMNativeAdData.init),
                                            writer: appendAssets,
                                            reader: { $0.dataObjects }),
                Decoding.ArrayPropertyCheck(value: try! (icons + images).map(PBMNativeAdImage.init),
                                            writer: appendAssets,
                                            reader: { $0.images }),
                Decoding.ArrayPropertyCheck(value: try! videos.map(PBMNativeAdVideo.init),
                                            writer: appendAssets,
                                            reader: { $0.videoAds }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: PBMNativeAdMarkup(link: .init(url: "")),
                                                 generator: PBMNativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testBaseArrayMethods()
        
        func testConvenienceGetters() {
            let optionalAdProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkup, PBMNativeAd>] = [
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
                Decoding.DefaultValuePropertyCheck(value: try! PBMNativeAdVideo(nativeAdMarkupAsset: videos[0]),
                                                   defaultValue: nil,
                                                   writer: { markup, str in appendMarkupAssets(markup, videos) },
                                                   reader: { $0.videoAd }),
                
                Decoding.ArrayPropertyCheck(value: ["some imptracker", "other imptraker"],
                                            writeKeyPath: \.imptrackers,
                                            readKeyPath: \.imptrackers),
            ]
            
            let nativeAdTester = Decoding.Tester(template: PBMNativeAdMarkup(link: .init(url: "")),
                                                 generator: PBMNativeAd.init(nativeAdMarkup:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalAdProperties)
            
            nativeAdTester.run()
        }
        testConvenienceGetters()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(PBMNativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))), NSObject())
        XCTAssertEqual(PBMNativeAd(nativeAdMarkup: .init(link: .init())),
                       PBMNativeAd(nativeAdMarkup: .init(link: .init())))
        XCTAssertEqual(PBMNativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))),
                       PBMNativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))))
        XCTAssertEqual(PBMNativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))),
                       PBMNativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))))
        XCTAssertNotEqual(PBMNativeAd(nativeAdMarkup: .init(link: .init(url: "v1"))),
                          PBMNativeAd(nativeAdMarkup: .init(link: .init(url: "w2"))))
    }
    
    func testMeassurementSession() {
        let application = MockUIApplication()
        let connection = MockServerConnection()
        let sdkConfiguration = PBMSDKConfiguration()
        
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
        nativeMarkup.eventtrackers = [PBMNativeAdMarkupEventTracker(event: .OMID,
                                                           method: .JS,
                                                           url: .init(""))]
        
        var nativeAd: PBMNativeAd? = PBMNativeAd(nativeAdMarkup: nativeMarkup,
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
        let sdkConfiguration = PBMSDKConfiguration()
        
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
        let nativeAd = PBMNativeAd(nativeAdMarkup: nativeMarkup,
                                   application: application,
                                   measurementWrapper: measurement,
                                   serverConnection: connection,
                                   sdkConfiguration: sdkConfiguration)
        
        nativeAd.register(UIView(), clickableViews: nil)
        
        wait(for: [expectationInitializeSession], timeout: 2);
    }
}
