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

import UIKit

@objc(PBMFunctions) @_spi(PBMInternal) public class Functions: NSObject {
    
    private override init() {
        super.init()
    }
    
    static func dictionary(from jsonString: String) throws -> [String: Any] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw PBMError.error(description: "Could not convert jsonString to data: \(jsonString)")
        }
        return try dictionary(from: jsonData)
    }
    
    static func dictionary(from jsonData: Data) throws -> [String: Any] {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)

        guard let dict = jsonObject as? [String: Any] else {
            throw PBMError.error(description: "Invalid JSON data: \(jsonData)")
        }

        return dict
    }

    /// Parses a JSON string into `[String: Any]` while preserving the original
    /// decimal precision of numeric leaves. Numbers are stored as `NSDecimalNumber`,
    /// so subsequent serialization via `JSONSerialization.data(withJSONObject:)`
    /// emits the same decimal text the publisher provided.
    ///
    /// Use this for publisher-supplied JSON (e.g. arbitrary ORTB) where values like
    /// `0.05` or `0.1` must round-trip exactly. The default `dictionary(from:)`
    /// uses `JSONSerialization`, which decodes numbers as `Double` and loses
    /// precision for values that aren't exactly representable in IEEE-754.
    static func dictionaryPreservingDecimals(from jsonString: String) throws -> [String: Any] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw PBMError.error(description: "Could not convert jsonString to data: \(jsonString)")
        }
        return try dictionaryPreservingDecimals(from: jsonData)
    }

    static func dictionaryPreservingDecimals(from jsonData: Data) throws -> [String: Any] {
        let node = try JSONDecoder().decode(JSONNode.self, from: jsonData)
        guard case let .object(dict) = node else {
            throw PBMError.error(description: "Invalid JSON data: top-level element is not an object")
        }
        return dict.mapValues { $0.unwrappedValue }
    }

    static func jsonString(from dictionary: [String: Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            throw PBMError.error(description: "Not valid JSON object: \(dictionary)")
        }
        
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [.sortedKeys])
        guard let string = String(data: data, encoding: .utf8) else {
            throw PBMError.error(description: "Could not convert JsonDictionary: \(dictionary)")
        }
        
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - ObjC bridge (PBMFunctions public API)

    @objc public static var sdkVersion: String {
        PrebidConstants.PREBID_VERSION
    }

    @objc public static var supportedSKAdNetworkVersions: [String] {
        var versions: [String] = []
        if #available(iOS 14.5, *) { versions.append("2.2") }
        if #available(iOS 14.6, *) { versions.append("3.0") }
        if #available(iOS 16.2, *) { versions.append("4.0") }
        return versions
    }

    @objc(extractVideoAdParamsFromTheURLString:forKeys:)
    public static func extractVideoAdParams(fromURLString urlString: String, forKeys keys: [Any]) -> [String: String] {
        var result: [String: String] = [:]
        guard let components = URLComponents(string: urlString) else { return result }
        if let host = components.host { result[PrebidConstants.DOMAIN_KEY] = host }
        for key in keys {
            guard let keyStr = key as? String else { continue }
            if let item = components.queryItems?.first(where: { $0.name == keyStr }), let value = item.value {
                result[keyStr] = value
            }
        }
        return result
    }

    @objc(canLoadVideoAdWithDomain:adUnitID:adUnitGroupID:)
    public static func canLoadVideoAd(withDomain domain: String?,
                                      adUnitID: String?,
                                      adUnitGroupID: String?) -> Bool {
        guard domain != nil else { return false }
        return adUnitID != nil || adUnitGroupID != nil
    }

    @objc(dictionariesForPassthrough:)
    public static func dictionariesForPassthrough(_ passthrough: Any) -> [[String: Any]]? {
        if let array = passthrough as? [[String: Any]] { return array }
        if let dict  = passthrough as? [String: Any]   { return [dict] }
        return nil
    }

    @objc public static var bundleForSDK: Bundle {
        let main = Bundle(for: Functions.self)
        if let path = main.path(forResource: "PrebidSDKCoreResources", ofType: "bundle"),
           let bundle = Bundle(path: path) { return bundle }
        return main
    }

    @objc(infoPlistValueFor:)
    public static func infoPlistValue(_ key: String) -> String? {
        guard !key.isEmpty else { return nil }
        return bundleForSDK.object(forInfoDictionaryKey: key) as? String
    }

    // MARK: - ObjC bridge (PBMFunctions+Private — URLs)

    @objc(attemptToOpen:)
    public static func attemptToOpen(_ url: URL) {
        let app: PBMUIApplicationProtocol = Functions.application ?? UIApplication.shared
        attemptToOpen(url, pbmUIApplication: app)
    }

    @objc(attemptToOpen:pbmUIApplication:)
    public static func attemptToOpen(_ url: URL, pbmUIApplication: PBMUIApplicationProtocol) {
        pbmUIApplication.open(url, options: [:], completionHandler: nil)
    }

    // MARK: - ObjC bridge (PBMFunctions+Private — Time)

    @objc(clamp:lowerBound:upperBound:)
    public static func clamp(_ value: TimeInterval,
                              lowerBound: TimeInterval,
                              upperBound: TimeInterval) -> TimeInterval {
        min(max(value, lowerBound), upperBound)
    }

    @objc(clampInt:lowerBound:upperBound:)
    public static func clampInt(_ value: Int, lowerBound: Int, upperBound: Int) -> Int {
        min(max(value, lowerBound), upperBound)
    }

    @objc(clampAutoRefresh:)
    public static func clampAutoRefresh(_ value: TimeInterval) -> TimeInterval {
        clamp(value,
              lowerBound: PrebidConstants.AUTO_REFRESH_DELAY_MIN,
              upperBound: PrebidConstants.AUTO_REFRESH_DELAY_MAX)
    }

    // DISPATCH_TIME_NOW / DISPATCH_TIME_FOREVER — the C macros are not exposed to Swift.
    private static let dispatchTimeNow: UInt64 = 0
    private static let dispatchTimeForever: UInt64 = .max

    @objc(dispatchTimeAfterTimeInterval:)
    public static func dispatchTimeAfterTimeInterval(_ timeInterval: TimeInterval) -> UInt64 {
        dispatchTimeAfterTimeInterval(timeInterval, startTime: dispatchTimeNow)
    }

    /// Swift equivalent of `dispatch_time(startTime, timeInterval * NSEC_PER_SEC)`.
    ///
    /// `startTime` is a raw `dispatch_time_t`. Values derived from `DISPATCH_TIME_NOW`
    /// are expressed in **mach ticks**, not nanoseconds, so they must not be round-tripped
    /// through `DispatchTime(uptimeNanoseconds:)` — that initialiser converts nanoseconds
    /// to ticks and yields a bogus deadline wherever `mach_timebase_info` is not 1:1
    /// (i.e. on arm64 devices; the simulator's 1:1 timebase hides the error).
    @objc(dispatchTimeAfterTimeInterval:startTime:)
    public static func dispatchTimeAfterTimeInterval(_ timeInterval: TimeInterval,
                                                     startTime: UInt64) -> UInt64 {
        switch startTime {
        case dispatchTimeNow:
            return (DispatchTime.now() + timeInterval).rawValue
        case dispatchTimeForever:
            return dispatchTimeForever
        default:
            return startTime &+ UInt64(bitPattern: machTicks(fromSeconds: timeInterval))
        }
    }

    private static func machTicks(fromSeconds seconds: TimeInterval) -> Int64 {
        var timebase = mach_timebase_info_data_t()
        guard mach_timebase_info(&timebase) == KERN_SUCCESS, timebase.numer != 0 else {
            return Int64(seconds * TimeInterval(NSEC_PER_SEC))
        }
        let nanoseconds = Int64(seconds * TimeInterval(NSEC_PER_SEC))
        return nanoseconds * Int64(timebase.denom) / Int64(timebase.numer)
    }

    // MARK: - ObjC bridge (PBMFunctions+Private — JSON)

    // Throwing methods: @objc name must include `:error:` — Swift does not auto-append it when explicit.
    @objc(dictionaryFromJSONString:error:)
    public static func dictionaryFromJSONString(_ jsonString: String) throws -> [String: Any] {
        try dictionary(from: jsonString)
    }

    @objc(dictionaryFromData:error:)
    public static func dictionaryFromData(_ jsonData: Data) throws -> [String: Any] {
        try dictionary(from: jsonData)
    }

    @objc(toStringJsonDictionary:error:)
    public static func toStringJsonDictionary(_ jsonDictionary: [String: Any]) throws -> String {
        try jsonString(from: jsonDictionary)
    }

    // MARK: - ObjC bridge (PBMFunctions+Private — UI)

    @objc public static var statusBarHeight: CGFloat {
        statusBarHeight(application: UIApplication.shared)
    }

    @objc(statusBarHeightForApplication:)
    public static func statusBarHeight(application: PBMUIApplicationProtocol) -> CGFloat {
        guard !application.isStatusBarHidden else { return 0 }
        if application.statusBarOrientation.isPortrait {
            return application.statusBarFrame.size.height
        }
        return application.statusBarFrame.size.width
    }

    // MARK: - ObjC bridge (PBMFunctions+Private — Device Info)

    @objc public static var deviceScreenSize: CGSize {
        UIScreen.main.bounds.size
    }

    @objc public static var deviceMaxSize: CGSize {
        let screenSize = deviceScreenSize
        let saInsets   = safeAreaInsets
        return CGSize(width:  screenSize.width  - saInsets.left - saInsets.right,
                      height: screenSize.height - statusBarHeight - saInsets.top - saInsets.bottom)
    }

    @objc public static var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
    }

    @objc public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    // MARK: -

    @objc
    public static func checkCertificateChallenge(_ challenge: URLAuthenticationChallenge,
                                                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Check if mock server host
        guard challenge.protectionSpace.host == "10.0.2.2" else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        var certificateHost: String?
        if let serverTrust = challenge.protectionSpace.serverTrust,
           let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
           let summary = SecCertificateCopySubjectSummary(certificate) {
            certificateHost = summary as String
        }
        
        let credential = challenge.protectionSpace.serverTrust.map {
            URLCredential(trust: $0)
        }
        
        // Only allow when involving 10.0.2.2 mock server host
        if certificateHost == "10.0.2.2" {
            completionHandler(.useCredential, credential)
        }
    }
}

private enum JSONNode: Decodable {
    case null
    case bool(Bool)
    case number(NSDecimalNumber)
    case string(String)
    case array([JSONNode])
    case object([String: JSONNode])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            // Decode Bool before Decimal so that `true` / `false` aren't mapped to 1 / 0.
            self = .bool(bool)
        } else if let decimal = try? container.decode(Decimal.self) {
            self = .number(NSDecimalNumber(decimal: decimal))
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONNode].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONNode].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported JSON value"
            )
        }
    }

    var unwrappedValue: Any {
        switch self {
        case .null:                return NSNull()
        case .bool(let value):     return value
        case .number(let value):   return value
        case .string(let value):   return value
        case .array(let nodes):    return nodes.map { $0.unwrappedValue }
        case .object(let dict):    return dict.mapValues { $0.unwrappedValue }
        }
    }
}

