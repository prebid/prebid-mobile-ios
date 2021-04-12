//
//  AppConfiguration.swift
//  OpenXInternalTestApp
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit
import RxSwift

final class AppConfiguration: NSObject {
    private let keyUseMockServer = "KeyUseMockServer"
    static let shared = AppConfiguration()
    
    private override init() {}
    
    var isAppStatusBarHidden = true
    private lazy var useMockServerSubject = BehaviorSubject<Bool>(value: useMockServer)
    lazy var useMockServerObservable = useMockServerSubject.asObservable()
    var useMockServer: Bool {
        get {
            return UserDefaults.standard.bool(forKey: keyUseMockServer)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: keyUseMockServer)
            useMockServerSubject.onNext(newValue)
        }
    }
    var nativeAdConfig: OXANativeAdConfiguration?
    var adPosition: OXAAdPosition?
    var videoPlacementType: OXAVideoPlacementType?
    var adUnitContext: [(key: String, value: String)]?
}
