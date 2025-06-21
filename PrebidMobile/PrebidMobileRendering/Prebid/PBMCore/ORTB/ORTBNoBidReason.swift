//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

// MARK: - 5.24: No-Bid Reason Codes

@objc(PBMORTBNoBidReasonCode)
public enum ORTBNoBidReasonCode: Int {
    case unknownError = 0
    case technicalError
    case invalidRequest
    case knownWebSpider
    case suspectedNonHumanTraffic
    case cloudDataCenterOrProxyIP
    case unsupportedDevice
    case blockedPublisherOrSite
    case unmatchedUser
    case dailyReaderCapMet
    case dailyDomainCapMet
}

@objcMembers
public class PBMORTBNoBidReason: NSObject {

    private override init() {
        super.init()
        fatalError("ORTBNoBidReason should not be instantiated.")
    }

    public static func noBidReason(from code: ORTBNoBidReasonCode) -> String {
        switch code {
        case .unknownError:
            return "Unknown Error"
        case .technicalError:
            return "Technical Error"
        case .invalidRequest:
            return "Invalid Request"
        case .knownWebSpider:
            return "Known Web Spider"
        case .suspectedNonHumanTraffic:
            return "Suspected Non-Human Traffic"
        case .cloudDataCenterOrProxyIP:
            return "Cloud, Data center, or Proxy IP"
        case .unsupportedDevice:
            return "Unsupported Device"
        case .blockedPublisherOrSite:
            return "Blocked Publisher or Site"
        case .unmatchedUser:
            return "Unmatched User"
        case .dailyReaderCapMet:
            return "Daily Reader Cap Met"
        case .dailyDomainCapMet:
            return "Daily Domain Cap Met"
        @unknown default:
            return noBidReason(from: .unknownError)
        }
    }
}
