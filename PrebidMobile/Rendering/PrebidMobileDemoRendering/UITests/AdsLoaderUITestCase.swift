//
//  AdsLoaderUITestCase.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

class AdsLoaderUITestCase: RepeatedUITestCase {

    // MARK: - Helpers
    
    func checkBannerLoadResult(exampleName: String,
                               video: Bool = false,
                               adapterBased: Bool = false,
                               callbacks: (Bool) -> (String) = defaultBannerCallbacks,
                               expectFailure: Bool = false,
                               file: StaticString = #file,
                               line: UInt = #line)
    {
        checkNonInterstitialLoadResult(exampleName: exampleName,
                                       video: video,
                                       doNotCheckBannerView: adapterBased,
                                       successCallback: callbacks(!expectFailure) + " called",
                                       failCallback: callbacks(expectFailure) + " called",
                                       expectFailure: expectFailure,
                                       file: file,
                                       line: line)
    }
    
    func checkNativeAdLoadResult(exampleName: String,
                                 video: Bool = false,
                                 successCallback: String,
                                 file: StaticString = #file,
                                 line: UInt = #line)
    {
        checkNonInterstitialLoadResult(exampleName: exampleName,
                                       video: video,
                                       doNotCheckBannerView: true,
                                       successCallback: successCallback,
                                       failCallback: nil,
                                       expectFailure: false,
                                       file: file,
                                       line: line)
    }
    
    
    private func checkNonInterstitialLoadResult(exampleName: String,
                                                video: Bool,
                                                doNotCheckBannerView: Bool,
                                                successCallback: String,
                                                failCallback: String?,
                                                expectFailure: Bool,
                                                file: StaticString,
                                                line: UInt)
    {
        repeatTesting(times: 7) {
            navigateToExamplesSection()
            navigateToExample(exampleName)

            let expectedOutcomeButton = app.buttons[successCallback]
            let unexpectedOutcomeButton = failCallback.map { app.buttons[$0] }
            let bannerView = app.descendants(matching: .other)["PBMBannerView"]
            
            if !doNotCheckBannerView {
                waitForExists(element: bannerView)
            }
            
            waitForEnabled(element: expectedOutcomeButton,
                           failElement: unexpectedOutcomeButton,
                           waitSeconds: 10,
                           file: file, line: line)
            
            if !doNotCheckBannerView {
                XCTAssertEqual(bannerView.children(matching: .any).count, expectFailure ? 0 : 1)
            }
        }
    }
    
    func checkInterstitialLoadResult(exampleName: String,
                                             callbacks: (Bool) -> (String) = defaultInterstitialCallbacks,
                                             expectFailure: Bool = false,
                                             file: StaticString = #file,
                                             line: UInt = #line)
    {
        repeatTesting(times: 3) {
            navigateToExamplesSection()
            navigateToExample(exampleName)
            
            let expectedOutcomeButton = app.buttons["\(callbacks(!expectFailure)) called"]
            let unexpectedOutcomeButton = app.buttons["\(callbacks(expectFailure)) called"]
            
            let loadTimeout = 20.0 // default setting for DFP
            
            waitForEnabled(element: expectedOutcomeButton,
                           failElement: unexpectedOutcomeButton,
                           waitSeconds: loadTimeout,
                           file: file, line: line)
            
            if (!expectFailure) {
                let showButton = app.buttons["Show"]
                waitForEnabled(element: showButton)
            }
        }
    }
    
    func checkRewardedLoadResult(exampleName: String,
                                         callbacks: (Bool) -> (String) = defaultRewardedCallbacks,
                                         expectFailure: Bool = false,
                                         file: StaticString = #file,
                                         line: UInt = #line)
    {
        checkInterstitialLoadResult(exampleName: exampleName,
                                    callbacks: callbacks,
                                    expectFailure: expectFailure,
                                    file: file,
                                    line: line)
    }
    
    func mopubBannerCallbacks(ok: Bool) -> String {
        return ok ? "adViewDidLoadAd" : "adViewDidFail"
    }
    func mopubInterstitialCallbacks(ok: Bool) -> String {
        return ok ? "interstitialDidLoadAd" : "interstitialDidFail"
    }
    func mopubRewardedCallbacks(ok: Bool) -> String {
        return ok ? "rewardedVideoAdDidLoad" : "rewardedVideoAdDidFailToLoad"
    }

    private static func defaultBannerCallbacks(ok: Bool) -> String {
        return ok ? "adViewDidReceiveAd" : "adViewDidFailToLoadAd"
    }
    private static func defaultInterstitialCallbacks(ok: Bool) -> String {
        return ok ? "interstitialDidReceiveAd" : "interstitialDidFailToReceiveAd"
    }
    private static func defaultRewardedCallbacks(ok: Bool) -> String {
        return ok ? "rewardedAdDidReceiveAd" : "rewardedAdDidFailToReceiveAd"
    }
}
