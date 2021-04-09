//
//  IABConsentHelper.swift
//  OpenXInternalTestApp
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import Foundation
import UIKit

class IABConsentHelper {
    private var settingUpdates: [NSDictionary]?
    private var timer: Timer?
    private var nextUpdate = 0
    
    func eraseIrrelevantUserDefaults() {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: IABConsentSettingKey.keepSettings) == false {
            userDefaults.removeObject(forKey: IABConsentSettingKey.TCF.v1.cmpPresent)
            userDefaults.removeObject(forKey: IABConsentSettingKey.TCF.v1.subjectToGDPR)
            userDefaults.removeObject(forKey: IABConsentSettingKey.TCF.v1.consentString)
            userDefaults.removeObject(forKey: IABConsentSettingKey.TCF.v2.cmpSdkId)
            userDefaults.removeObject(forKey: IABConsentSettingKey.TCF.v2.subjectToGDPR)
            userDefaults.removeObject(forKey: IABConsentSettingKey.TCF.v2.consentString)
            userDefaults.removeObject(forKey: IABConsentSettingKey.usPrivacyString)
        }
    }
    
    func parseAndApply(consentSettingsString: String) {
        guard let iabSettings = try? JSONSerialization.jsonObject(with: consentSettingsString.data(using: .utf8)!, options: []) as? NSDictionary else {
            return
        }
        if let launchOptions = iabSettings["launchOptions"] as? NSDictionary {
            apply(iabSettings: launchOptions)
        }
        if let delay = (iabSettings["updateInterval"] as? NSNumber)?.floatValue,
            let updatedOptions = iabSettings["updatedOptions"] as? [NSDictionary],
            updatedOptions.count > 0
        {
            settingUpdates = updatedOptions
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(onTimerTicked), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func onTimerTicked(timer: Timer) {
        guard let settingUpdates = self.settingUpdates else {
            return
        }
        self.apply(iabSettings: settingUpdates[self.nextUpdate])
        self.nextUpdate += 1
        if self.nextUpdate >= self.settingUpdates?.count ?? 0 {
            self.timer?.invalidate()
            self.timer = nil
            self.settingUpdates = nil
            self.nextUpdate = 0
        }
    }
    
    func apply(iabSettings: NSDictionary) {
        let userDefaults = UserDefaults.standard
        
        let isWithAllowedPrefix: (String) -> Bool = { s in
            for prefix in IABConsentSettingKey.allowedPrefixes {
                if s.starts(with: prefix) {
                    return true
                }
            }
            return false
        }
        
        for (key, obj) in iabSettings as? [String: NSObject] ?? [:] {
            guard isWithAllowedPrefix(key) else {
                continue
            }
            if obj is NSNull {
                userDefaults.removeObject(forKey: key)
            } else {
                userDefaults.set(obj, forKey: key)
            }
        }
    }
    
    
}
