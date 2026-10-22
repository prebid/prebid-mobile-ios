# Public API removed by Phase 9

Generated from the `.swiftinterface` of the iOS device slice before (`master`, `c597bc07`) and after this PR (head after the review fixes): a declaration-level diff of the `public`/`open` lines, attributes normalised. The documented members restored after review (`isMuted`, `isSoundButtonVisible`, `getImpORTBConfig()`, `getGlobalORTBConfig()` on the interstitial and rewarded units, `Host.setHostURL`/`getHostURL`) are not in it. Use it to write the release notes.

## Removed public types (89)

`AdMarkupStringHandler`, `AdViewButtonDecorator`, `ArbitraryORTBService`, `BackgroundAwareTimer`, `BannerBasedAdUnitProtocol`, `BannerEventHandlerStandalone`, `CircularProgressBarLayer`, `CircularProgressBarView`, `ClickbrowserType`, `DateFormatService`, `DeepLinkPlus`, `DefaultPluginEventDelegate`, `DemandResponseInfo`, `DeviceAccessManager`, `DeviceAccessManagerKeys`, `DisplayViewVideoPlaybackDelegate`, `DownloadDataHelper`, `HiddenWebViewManager`, `ImpressionTasksExecutor`, `InterstitialController`, `InterstitialEventHandlerStandalone`, `LocationManager`, `MRAIDCloseButtonPosition`, `MRAIDCloseButtonSize`, `MRAIDConstants`, `MRAIDExpandProperties`, `MRAIDParseKeys`, `MRAIDResizeProperties`, `MRAIDValues`, `MediationBidInfoWrapper`, `NetworkType`, `ORTBApp`, `ORTBAppContent`, `ORTBAppExt`, `ORTBAppExtPrebid`, `ORTBBanner`, `ORTBBidRequest`, `ORTBBidRequestExtPrebid`, `ORTBContentData`, `ORTBContentProducer`, `ORTBContentSegment`, `ORTBDeal`, `ORTBDevice`, `ORTBDeviceExtAtts`, `ORTBDeviceExtPrebid`, `ORTBDeviceExtPrebidInterstitial`, `ORTBFormat`, `ORTBGeo`, `ORTBImp`, `ORTBImpExtPrebid`, `ORTBImpExtSkadn`, `ORTBNative`, `ORTBNoBidReasonCode`, `ORTBPmp`, `ORTBPublisher`, `ORTBRegs`, `ORTBRendererConfig`, `ORTBSource`, `ORTBSourceExtOMID`, `ORTBUser`, `ORTBVideo`, `PBMDownloadDataCompletionClosure`, `PBMJsonEncodable`, `PBMNetworkReachableBlock`, `PBMORTBNoBidReason`, `PBMUIApplicationProtocol`, `PBMURLComponents`, `ParameterBuilder`, `ParameterBuilderService`, `PathBuilder`, `PrebidImagesRepository`, `PrebidJSLibrary`, `PrebidJSLibraryContentsCallback`, `PrebidJSLibraryManager`, `PrebidMobilePluginRegister`, `PrebidRenderer`, `PrebidServerEventTracker`, `Reachability`, `RewardedEventHandlerStandalone`, `SDKConsoleLogger`, `SKOverlayManager`, `ServerEvent`, `SkadnParametersManager`, `VASTError`, `VastResourceType`, `VideoBasedAdUnitProtocol`, `WKScriptMessageHandlerLeakAvoider`, `WeakTimerTargetBox`, `WinNotifierBlock`

## Removed public members of types that stay public (161 in 33 types)

### `AdConfiguration`
- `override public var autoRefreshDelay: Foundation.TimeInterval? {`
- `public var clickHandlerOverride: ((() -> Swift.Void) -> Swift.Void)?`
- `public var forceInterstitialPresentation: Foundation.NSNumber?`
- `public var globalORTBConfig: Swift.String?`
- `public var impORTBConfig: Swift.String?`
- `public var interstitialLayout: PrebidMobile.InterstitialLayout`
- `public var isBuiltInVideo: Swift.Bool`
- `public var isOriginalAPI: Swift.Bool`
- `public var pollFrequency: Swift.Double`
- `public var presentAsInterstitial: Swift.Bool {`
- `public var rewardedConfig: PrebidMobile.RewardedConfig?`
- `public var viewableArea: Swift.Int`
- `public var viewableDuration: Swift.Int`
- `public var winningBidAdFormat: PrebidMobile.AdFormat?`

### `AdDetails`
- `final public let rawResponse: Swift.String`
- `final public let transactionId: Swift.String`

### `AutoRefreshCountConfig`
- `public var autoRefreshDelay: Foundation.TimeInterval?`
- `public var autoRefreshMax: Swift.Double?`
- `public var numRefreshes: Swift.Int`

### `EventManager`
- `public func registerTracker(_ tracker: any PrebidMobile.EventTrackerProtocol)`
- `public func unregisterAllTrackers()`
- `public func unregisterTracker(_ tracker: any PrebidMobile.EventTrackerProtocol)`

### `Host`
- `public func verifyUrl(urlString: Swift.String?) -> Swift.Bool`

### `InterstitialDisplayProperties`
- `override public init()`
- `public func getCloseButtonImage() -> UIKit.UIImage?`
- `public func setButtonImageHidden()`
- `public var closeDelay: Swift.Double`
- `public var closeDelayLeft: Swift.Double`
- `public var contentFrame: CoreFoundation.CGRect`
- `public var contentViewColor: UIKit.UIColor`
- `public var interstitialLayout: PrebidMobile.InterstitialLayout`
- `public var isRotationEnabled: Swift.Bool {`

### `ModalViewController`
- `override public init(nibName nibNameOrNil: Swift.String?, bundle nibBundleOrNil: Foundation.Bundle?)`
- `public func addFriendlyObstructions(toMeasurementSession session: (any PrebidMobile.OMSession)?)`
- `required public init?(coder: Foundation.NSCoder)`

### `NSDictionary`
- `public func nullIfEmpty() -> Any`

### `NSException`
- `public static func pbmException(_ message: Swift.String) -> Foundation.NSException`

### `NSMutableDictionary`
- `public func pbmCopyWithoutEmptyVals() -> Foundation.NSMutableDictionary`
- `public func pbmRemoveEmptyVals()`

### `NSString`
- `public func PBMdoesMatch(_ regex: Swift.String) -> Swift.Bool`
- `public func PBMnumberOfMatches(_ regex: Swift.String) -> Swift.Int32`
- `public func PBMstringByReplacingRegex(_ regex: Swift.String?, replaceWith replacement: Swift.String?) -> Swift.String`
- `public func PBMsubstringFromIndex(_ fromIndex: Swift.Int32, toIndex: Swift.Int32) -> Swift.String?`
- `public func PBMsubstringFromString(_ from: Swift.String?) -> Swift.String?`
- `public func PBMsubstringFromString(_ from: Swift.String?, toString to: Swift.String?) -> Swift.String?`
- `public func PBMsubstringToString(_ to: Swift.String?) -> Swift.String?`
- `public var base64DecodedImage: UIKit.UIImage? {`

### `NSURL`
- `public static func pbmURLWithoutEncoding(from str: Swift.String?) -> Foundation.URL?`

### `NativeAdConfiguration`
- `override public init()`
- `public var markupRequestObject: PrebidMobile.NativeMarkupRequestObject`

### `NativeAdMarkupAsset`
- `override public init()`
- `required public init(jsonDictionary: [Swift.String : Any])`

### `NativeData`
- `override public init()`
- `required public init(jsonDictionary: [Swift.String : Any])`

### `NativeEventTrackerResponse`
- `override public init()`
- `required public init(jsonDictionary: [Swift.String : Any])`

### `NativeImage`
- `override public init()`
- `required public init(jsonDictionary: [Swift.String : Any])`

### `NativeMarkupRequestObject`
- `override public init()`
- `public func toJsonString() throws -> Swift.String`
- `public var aurlsupport: Swift.Int`
- `public var contextsubtype: PrebidMobile.ContextSubType?`
- `public var durlsupport: Swift.Int`
- `public var plcmtcnt: Swift.Int`
- `public var plcmttype: PrebidMobile.PlacementType?`
- `public var seq: Swift.Int`

### `NativeTitle`
- `override public init()`
- `required public init(jsonDictionary: [Swift.String : Any])`

### `PBMJsonDecodable`
- `public init?(jsonString: Swift.String) throws`

### `PrebidConstants`
- `public static let ACCESSIBILITY_BANNER_VIEW: Swift.String`
- `public static let ACCESSIBILITY_CLOSE_BUTTON_CLICK_THROUGH_BROWSER_IDENTIFIER: Swift.String`
- `public static let ACCESSIBILITY_CLOSE_BUTTON_CLICK_THROUGH_BROWSER_LABEL: Swift.String`
- `public static let ACCESSIBILITY_CLOSE_BUTTON_IDENTIFIER: Swift.String`
- `public static let ACCESSIBILITY_CLOSE_BUTTON_LABEL: Swift.String`
- `public static let ACCESSIBILITY_VIDEO_AD_VIEW: Swift.String`
- `public static let ACCESSIBILITY_WEB_VIEW_LABEL: Swift.String`
- `public static let AD_CLICKED_ALLOWED_INTERVAL: Swift.Double`
- `public static let AD_PREFETCH_TIME: Swift.Double`
- `public static let APP_STORE_URL_SCHEME: Swift.String`
- `public static let AUTO_REFRESH_DELAY_DEFAULT: Swift.Double`
- `public static let AUTO_REFRESH_DELAY_MAX: Swift.Double`
- `public static let AUTO_REFRESH_DELAY_MIN: Swift.Double`
- `public static let BUTTON_AREA_DEFAULT: Foundation.NSNumber`
- `public static let BUTTON_CONSTRAINT: Foundation.NSNumber`
- `public static let CLOSE_DELAY_MAX: Swift.Double`
- `public static let CLOSE_DELAY_MIN: Swift.Double`
- `public static let CONNECTION_TIMEOUT_DEFAULT: Swift.Double`
- `public static let DISTANCE_FILTER: Swift.Double`
- `public static let DOMAIN_KEY: Swift.String`
- `public static let FETCH_DEMAND_RESULT_KEY: Swift.String`
- `public static let FIRE_AND_FORGET_TIMEOUT: Swift.Double`
- `public static let LOCATION_SOURCE_GPS: Swift.Int`
- `public static let LOCATION_SOURCE_IPAddress: Swift.Int`
- `public static let LOCATION_SOURCE_USER_REGISTRATION: Swift.Int`
- `public static let OPEN_RTB_SCHEME: Swift.String`
- `public static let PBM_ORIGINAL_ADUNIT_KEY: Swift.String`
- `public static let PBM_PRECACHE_CONFIGURATION_KEY: Swift.String`
- `public static let PBM_TRACKING_URL_TEMPLATE: Swift.String`
- `public static let PBM_TRANSACTION_STATE_KEY: Swift.String`
- `public static let PREBID_VERSION: Swift.String`
- `public static let SDK_NAME: Swift.String`
- `public static let SERVER_ENDPOINTS_STATUS: Swift.String`
- `public static let SKIP_DELAY_DEFAULT: Foundation.NSNumber`
- `public static let SUPPORTED_VIDEO_MIME_TYPES: [Swift.String]`
- `public static let TRACKING_PATTERN_BO: Swift.String`
- `public static let TRACKING_PATTERN_RC: Swift.String`
- `public static let TRACKING_PATTERN_RDF: Swift.String`
- `public static let TRACKING_PATTERN_RI: Swift.String`
- `public static let TRACKING_PATTERN_RR: Swift.String`
- `public static let URL_SCHEMES_FOR_APP_STORE_AND_ITUNES: [Swift.String]`
- `public static let URL_SCHEMES_NOT_SUPPORTED_ON_CLICKTHROUGH_BROWSER: [Swift.String]`
- `public static let URL_SCHEMES_NOT_SUPPORTED_ON_SIMULATOR: [Swift.String]`
- `public static let VAST_LOADER_TIMEOUT: Swift.Double`
- `public static let VIDEO_TIMESCALE: Swift.Int`
- `public static var companionHTMLTemplate: Swift.String {`
- `public static var supportedRenderingBannerAPISignals: [PrebidMobile.Signals.Api] {`

### `PrebidServerConnection`
- `convenience public init(userAgentService: PrebidMobile.UserAgentService)`
- `public static var contentTypeKey: Swift.String {`
- `public static var contentTypeVal: Swift.String {`
- `public static var userAgentHeaderKey: Swift.String {`
- `public var protocolClasses: [Foundation.URLProtocol.Type]`

### `PrebidServerResponse`
- `public var isOKStatusCode: Swift.Bool {`
- `public var jsonDict: [Swift.String : Any]?`
- `public var rawData: Foundation.Data?`
- `public var requestHeaders: [Swift.String : Swift.String]?`
- `public var requestURL: Swift.String?`
- `public var responseHeaders: [Swift.String : Swift.String]?`

### `RewardedConfig`
- `final public let defaultCompletionTime: Foundation.NSNumber`
- `final public let defaultVideoPlaybackEvent: Swift.String`
- `public init(ortbRewarded: PrebidMobile.ORTBRewardedConfiguration?)`
- `public var bannerEvent: Swift.String? {`
- `public var bannerTime: Foundation.NSNumber? {`
- `public var closeAction: Swift.String? {`
- `public var endcardEvent: Swift.String? {`
- `public var endcardTime: Foundation.NSNumber? {`
- `public var postRewardTime: Foundation.NSNumber? {`
- `public var videoPlaybackevent: Swift.String? {`
- `public var videoTime: Foundation.NSNumber? {`

### `SkadnEventTracker`
- `public init(with imp: StoreKit.SKAdImpression)`

### `Timer`
- `public static func pbmScheduledTimerFactory() -> (Foundation.TimeInterval, Swift.AnyObject, ObjectiveC.Selector, Any?, Swift.Bool) -> any PrebidMobile.TimerInterface`

### `UIApplication`
- `public var pbmKeyWindow: UIKit.UIWindow? {`

### `UIView`
- `public func PBMAddBottomLeftConstraints(viewSize: CoreFoundation.CGSize, marginSize: CoreFoundation.CGSize)`
- `public func PBMAddBottomRightConstraints(viewSize: CoreFoundation.CGSize, marginSize: CoreFoundation.CGSize)`
- `public func PBMAddBottomRightConstraintsWithMarginSize(_ marginSize: CoreFoundation.CGSize)`
- `public func PBMAddTopLeftConstraints(viewSize: CoreFoundation.CGSize, marginSize: CoreFoundation.CGSize)`
- `public func PBMAddTopRightConstraints(viewSize: CoreFoundation.CGSize, marginSize: CoreFoundation.CGSize)`
- `public func logViewHierarchy()`
- `public func pbmIsVisibleInView(_ inView: UIKit.UIView) -> Swift.Bool`

### `UIWindow`
- `public static func appVisibleViewController() -> UIKit.UIViewController?`
- `public static func getVisibleViewControllerFrom(_ vc: UIKit.UIViewController) -> UIKit.UIViewController?`

### `UserAgentService`
- `public func fetchUserAgent(completion: ((Swift.String) -> Swift.Void)? = nil)`

### `VastTrackingEvents`
- `public func addTrackingEvents(_ events: PrebidMobile.VastTrackingEvents?)`
- `public func addTrackingURL(_ url: Swift.String?, event: Swift.String?, attributes: [Swift.String : Swift.String]?)`
- `public func trackingURLs(forEvent event: Swift.String?) -> [Swift.String]?`

### `VideoVerificationParameters`
- `public var autoPlay: Swift.Bool`
- `public var verificationResources: [PrebidMobile.VideoVerificationResource]`

### `VideoVerificationResource`
- `public var apiFramework: Swift.String?`
- `public var params: Swift.String?`
- `public var trackingEvents: PrebidMobile.VastTrackingEvents?`
- `public var url: Swift.String?`
- `public var vendorKey: Swift.String?`
