//
//  MPAdServerURLBuilder.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerURLBuilder.h"
#import <CoreTelephony/CTCarrier.h>

#import <CoreLocation/CoreLocation.h>
// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

#import "MPAdServerKeys.h"
#import "MPConsentManager.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider+MRAID.h"
#import "MPError.h"
#import "MPGlobal.h"
#import "MPIdentityProvider.h"
#import "MPLogging.h"
#import "MPMediationManager.h"
#import "MPRateLimitManager.h"
#import "MPSKAdNetworkManager.h"
#import "MPViewabilityManager.h"
#import "NSString+MPAdditions.h"
#import "NSString+MPConsentStatus.h"

static NSString * const kMoPubInterfaceOrientationPortrait = @"p";
static NSString * const kMoPubInterfaceOrientationLandscape = @"l";
static NSInteger const kAdSequenceNone = -1;

@interface MPAdServerURLBuilder ()

/**
 Builds an NSMutableDictionary with all generic URL parameters and their values. This base set of parameters
 includes the following:
 - Server API Version Used (`v`)
 - SDK Version (`nv`)
 - Engine Name (`e_name`)
 - Engine Version (`e_ver`)
 - Application Version (`av`)
 - GDPR Region Applicable (`gdpr_applies`)
 - Current Consent Status (`current_consent_status`)
 - Limit Ad Tracking Status (`dnt`)
 - Tracking Authorization Status Description String (`tas`)
 - Bundle Identifier (`bundle`)
 - MoPub ID (`mid`)
 - IF AVAILABLE: Consented Privacy Policy Version (`consented_privacy_policy_version`)
 - IF AVAILABLE: Consented Vendor List Version (`consented_vendor_list_version`)
 */
+ (NSMutableDictionary *)baseParametersDictionary;

/**
 Builds an NSMutableDictionary with all generic URL parameters and their values, as well as an `id` parameter.
 The `id` URL parameter is gathered from the @c idParameter` method parameter because it has different uses
 depending on the URL.
 */
+ (NSMutableDictionary *)baseParametersDictionaryWithIDParameter:(NSString *)idParameter;

// Location authorization status is specified as a class property to facilitate
// unit testing.
+ (MPLocationAuthorizationStatus)locationAuthorizationStatus;

// Identifier for vendor is specified as a class property to facilitate unit testing.
+ (NSString *)ifv;

// Identifier for advertiser is specified as a class property to facilitate unit testing.
+ (NSString *)ifa;

// MoPub identifier is specified as a class property to facilitate unit testing.
+ (NSString *)mopubId;

@end

@implementation MPAdServerURLBuilder

#pragma mark - Static Properties

static NSString* _engineName = nil;
static NSString* _engineVersion = nil;

+ (NSString *)engineName {
    return _engineName;
}

+ (void)setEngineName:(NSString *)name {
    _engineName = name;
}

+ (NSString *)engineVersion {
    return _engineVersion;
}

+ (void)setEngineVersion:(NSString *)version {
    _engineVersion = version;
}

#pragma mark - URL Building

+ (MPURL *)URLWithComponents:(NSURLComponents *)components postData:(NSDictionary *)parameters {
    // Build the full URL string
    return [MPURL URLWithComponents:components postData:parameters];
}

+ (NSMutableDictionary *)baseParametersDictionary {
    MPConsentManager * manager = MPConsentManager.sharedManager;
    NSMutableDictionary * queryParameters = [NSMutableDictionary dictionary];

    // REQUIRED: Server API Version
    queryParameters[kServerAPIVersionKey] = MP_SERVER_VERSION;

    // REQUIRED: SDK Version
    queryParameters[kSDKVersionKey] = MP_SDK_VERSION;

    // REQUIRED: SDK Engine Information
    queryParameters[kSDKEngineNameKey] = self.engineName;
    queryParameters[kSDKEngineVersionKey] = self.engineVersion;

    // REQUIRED: Application Version
    queryParameters[kApplicationVersionKey] = [self applicationVersion];

    // REQUIRED: GDPR region applicable
    if (manager.isGDPRApplicable != MPBoolUnknown) {
        queryParameters[kGDPRAppliesKey] = manager.isGDPRApplicable > 0 ? @"1" : @"0";
    }

    // REQUIRED: GDPR applicable was forced
    queryParameters[kForceGDPRAppliesKey] = manager.forceIsGDPRApplicable ? @"1" : @"0";

    // REQUIRED: Current consent status
    queryParameters[kCurrentConsentStatusKey] = [NSString stringFromConsentStatus:manager.currentStatus];

    // REQUIRED: DNT, Tracking Authorization Status, Bundle
    queryParameters[kDoNotTrackIdKey] = [MPIdentityProvider advertisingTrackingEnabled] ? nil : @"1";

    queryParameters[kTrackingAuthorizationStatusKey] = MPIdentityProvider.trackingAuthorizationStatusDescription;

    queryParameters[kBundleKey] = [[NSBundle mainBundle] bundleIdentifier];

    // REQUIRED: MoPub ID
    // After user consented IDFA access, UDID uses IDFA and thus different from MoPub ID.
    // Otherwise, UDID is the same as MoPub ID.
    queryParameters[kMoPubIDKey] = [self mopubId];

    // REQUIRED: Identifier for Vendor
    queryParameters[kIdentifierForVendorKey] = [self ifv];

    // OPTIONAL: Identifier for Advertiser if available.
    queryParameters[kIdentifierForAdvertiserKey] = [self ifa];

    // OPTIONAL: Consented versions
    queryParameters[kConsentedPrivacyPolicyVersionKey] = manager.consentedPrivacyPolicyVersion;
    queryParameters[kConsentedVendorListVersionKey] = manager.consentedVendorListVersion;

    // OPTIONAL: Additional device information for debugging
    queryParameters[kOSKey] = @"ios";
    queryParameters[kDeviceNameKey] = [self deviceNameValue];
    queryParameters[kAdUnitKey] = [MPConsentManager sharedManager].adUnitIdUsedForConsent;

    // REQUIRED: Location authorization status
    MPLocationAuthorizationStatus locationAuthorizationStatus = [self locationAuthorizationStatus];
    queryParameters[kLocationAuthorizationStatusKey] = [MPDeviceInformation stringFromLocationAuthorizationStatus:locationAuthorizationStatus];

    return queryParameters;
}

+ (NSMutableDictionary *)baseParametersDictionaryWithIDParameter:(NSString *)idParameter {
    NSMutableDictionary * queryParameters = [self baseParametersDictionary];

    // REQUIRED: ID Parameter (used for different things depending on which URL, take from method parameter)
    queryParameters[kAdServerIDKey] = idParameter;

    return queryParameters;
}

+ (NSString *)applicationVersion {
    return MPDeviceInformation.applicationVersion;
}

+ (NSString *)deviceNameValue
{
    NSString *deviceName = [[UIDevice currentDevice] mp_hardwareDeviceName];
    return deviceName;
}

+ (MPLocationAuthorizationStatus)locationAuthorizationStatus {
    return MPDeviceInformation.locationAuthorizationStatus;
}

+ (NSString *)ifv {
    return MPIdentityProvider.ifv;
}

+ (NSString *)ifa {
    return MPIdentityProvider.ifa;
}

+ (NSString *)mopubId {
    return MPIdentityProvider.mopubId;
}

@end

@implementation MPAdServerURLBuilder (Ad)

+ (MPURL *)URLWithAdUnitID:(NSString *)adUnitID
                 targeting:(MPAdTargeting *)targeting
{
    return [self URLWithAdUnitID:adUnitID
                       targeting:targeting
                   desiredAssets:nil];
}

+ (MPURL *)URLWithAdUnitID:(NSString *)adUnitID
                 targeting:(MPAdTargeting *)targeting
             desiredAssets:(NSArray *)assets
{


    return [self URLWithAdUnitID:adUnitID
                       targeting:targeting
                   desiredAssets:assets
                      adSequence:kAdSequenceNone];
}

+ (MPURL *)URLWithAdUnitID:(NSString *)adUnitID
                 targeting:(MPAdTargeting *)targeting
             desiredAssets:(NSArray *)assets
                adSequence:(NSInteger)adSequence
{
    NSMutableDictionary * queryParams = [self baseParametersDictionaryWithIDParameter:adUnitID];

    queryParams[kOrientationKey]                   = [self orientationValue];
    queryParams[kScaleFactorKey]                   = [self scaleFactorValue];
    queryParams[kTimeZoneKey]                      = [self timeZoneValue];
    queryParams[kIsMRAIDEnabledSDKKey]             = [self isMRAIDEnabledSDKValue];
    queryParams[kConnectionTypeKey]                = [self connectionTypeValue];
    queryParams[kCarrierNameKey]                   = MPDeviceInformation.cellularService.carrier.carrierName;
    queryParams[kISOCountryCodeKey]                = MPDeviceInformation.cellularService.carrier.isoCountryCode;
    queryParams[kMobileNetworkCodeKey]             = MPDeviceInformation.cellularService.carrier.mobileNetworkCode;
    queryParams[kMobileCountryCodeKey]             = MPDeviceInformation.cellularService.carrier.mobileCountryCode;
    queryParams[kDesiredAdAssetsKey]               = [self desiredAdAssetsValue:assets];
    queryParams[kAdSequenceKey]                    = [self adSequenceValue:adSequence];
    queryParams[kScreenResolutionWidthKey]         = [self physicalScreenResolutionWidthValue];
    queryParams[kScreenResolutionHeightKey]        = [self physicalScreenResolutionHeightValue];
    queryParams[kCreativeSafeWidthKey]             = [self creativeSafeWidthValue:targeting.creativeSafeSize];
    queryParams[kCreativeSafeHeightKey]            = [self creativeSafeHeightValue:targeting.creativeSafeSize];
    queryParams[kAppTransportSecurityStatusKey]    = [self appTransportSecurityStatusValue];
    queryParams[kKeywordsKey]                      = [self keywordsValue:targeting.keywords];
    queryParams[kUserDataKeywordsKey]              = [self userDataKeywordsValue:targeting.userDataKeywords];
    queryParams[kViewabilityStatusKey]             = [self viewabilityStatusValue];
    queryParams[kViewabilityVersionKey]            = MPViewabilityManager.sharedManager.omidVersion;
    queryParams[kAdvancedBiddingKey]               = [self advancedBiddingValue];
    queryParams[kBackoffMsKey]                     = [self backoffMillisecondsValueForAdUnitID:adUnitID];
    queryParams[kBackoffReasonKey]                 = [[MPRateLimitManager sharedInstance] lastRateLimitReasonForAdUnitId:adUnitID];
    queryParams[kSKAdNetworkHashKey]               = MPSKAdNetworkManager.sharedManager.lastSyncHash;
    queryParams[kSKAdNetworkLastSyncTimestampKey]  = MPSKAdNetworkManager.sharedManager.lastSyncTimestampEpochSeconds;
    queryParams[kSKAdNetworkLastSyncAppVersionKey] = MPSKAdNetworkManager.sharedManager.lastSyncAppVersion;
    [queryParams addEntriesFromDictionary:self.locationInformation];

    return [self URLWithComponents:MPAPIEndpoints.adRequestURLComponents postData:queryParams];
}

+ (NSString *)orientationValue
{
    // Starting with iOS8, the orientation of the device is taken into account when
    // requesting the key window's bounds.
    CGRect appBounds = [UIApplication sharedApplication].keyWindow.bounds;
    return appBounds.size.width > appBounds.size.height ? kMoPubInterfaceOrientationLandscape : kMoPubInterfaceOrientationPortrait;
}

+ (NSString *)scaleFactorValue
{
    return [NSString stringWithFormat:@"%.1f", MPDeviceScaleFactor()];
}

+ (NSString *)timeZoneValue
{
    static NSDateFormatter *formatter;
    @synchronized(self)
    {
        if (!formatter) formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:@"Z"];
    NSDate *today = [NSDate date];
    return [formatter stringFromDate:today];
}

+ (NSString *)isMRAIDEnabledSDKValue
{
    BOOL isMRAIDEnabled = [[MPCoreInstanceProvider sharedProvider] isMraidJavascriptAvailable] &&
                          NSClassFromString(@"MPMoPubInlineAdAdapter") != Nil &&
                          NSClassFromString(@"MPFullscreenAdAdapter") != Nil;
    return isMRAIDEnabled ? @"1" : nil;
}

+ (NSString *)connectionTypeValue
{
    return [NSString stringWithFormat:@"%ld", (long)MPDeviceInformation.currentNetworkStatus];
}

+ (NSString *)desiredAdAssetsValue:(NSArray *)assets
{
    NSString *concatenatedAssets = [assets componentsJoinedByString:@","];
    return [concatenatedAssets length] ? concatenatedAssets : nil;
}

+ (NSString *)adSequenceValue:(NSInteger)adSequence
{
    return (adSequence >= 0) ? [NSString stringWithFormat:@"%ld", (long)adSequence] : nil;
}

+ (NSString *)physicalScreenResolutionWidthValue
{
    return [NSString stringWithFormat:@"%.0f", MPScreenResolution().width];
}

+ (NSString *)physicalScreenResolutionHeightValue
{
    return [NSString stringWithFormat:@"%.0f", MPScreenResolution().height];
}

+ (NSString *)creativeSafeWidthValue:(CGSize)creativeSafeSize
{
    CGFloat scale = MPDeviceScaleFactor();
    return [NSString stringWithFormat:@"%.0f", creativeSafeSize.width * scale];
}

+ (NSString *)creativeSafeHeightValue:(CGSize)creativeSafeSize
{
    CGFloat scale = MPDeviceScaleFactor();
    return [NSString stringWithFormat:@"%.0f", creativeSafeSize.height * scale];
}

+ (NSString *)appTransportSecurityStatusValue
{
    return [NSString stringWithFormat:@"%@", @(MPDeviceInformation.appTransportSecuritySettingsValue)];
}

+ (NSString *)keywordsValue:(NSString *)keywords
{
    return keywords;
}

+ (NSString *)userDataKeywordsValue:(NSString *)userDataKeywords
{
    // Avoid sending user data keywords if we are not allowed to collect personal info
    if (![MPConsentManager sharedManager].canCollectPersonalInfo) {
        return nil;
    }

    return userDataKeywords;
}

+ (NSString *)viewabilityStatusValue {
    BOOL isViewabilityEnabled = MPViewabilityManager.sharedManager.isEnabled;

    // The value of the `vv` parameter is a bitmask describing which Viewability
    // vendors are enabled.
    // The only valid value post Open Measurement integration is 0x100 (4) which
    // represents that Open Measurement Viewability collection is enabled.
    return isViewabilityEnabled ? @"4" : @"0";
}

+ (NSString *)advancedBiddingValue {
    // Retrieve the tokens
    NSDictionary * tokens = MPMediationManager.sharedManager.advancedBiddingTokens;
    if (tokens == nil) {
        return nil;
    }

    // Serialize the JSON dictionary into a JSON string.
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:tokens options:0 error:&error];
    if (jsonData == nil) {
        NSError * jsonError = [NSError serializationOfJson:tokens failedWithError:error];
        MPLogEvent([MPLogEvent error:jsonError message:nil]);
        return nil;
    }

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)backoffMillisecondsValueForAdUnitID:(NSString *)adUnitID {
    NSUInteger lastRateLimitWaitTimeMilliseconds = [[MPRateLimitManager sharedInstance] lastRateLimitMillisecondsForAdUnitId:adUnitID];
    return lastRateLimitWaitTimeMilliseconds > 0 ? [NSString stringWithFormat:@"%@", @(lastRateLimitWaitTimeMilliseconds)] : nil;
}

+ (NSDictionary *)adapterInformation {
    return MPMediationManager.sharedManager.adRequestPayload;
}

+ (NSDictionary *)locationInformation {
    // Not allowed to collect location because it is PII
    if (![MPConsentManager.sharedManager canCollectPersonalInfo]) {
        return @{};
    }

    NSMutableDictionary *locationDict = [NSMutableDictionary dictionary];

    CLLocation *bestLocation = MPDeviceInformation.lastLocation;
    if (bestLocation != nil && bestLocation.horizontalAccuracy >= 0) {
        locationDict[kLocationLatitudeLongitudeKey] = [NSString stringWithFormat:@"%@,%@",
                                                       @(bestLocation.coordinate.latitude),
                                                       @(bestLocation.coordinate.longitude)];
        if (bestLocation.horizontalAccuracy) {
            locationDict[kLocationHorizontalAccuracy] = [NSString stringWithFormat:@"%@", @(bestLocation.horizontalAccuracy)];
        }

        // Only SDK-specified locations are allowed.
        locationDict[kLocationIsFromSDK] = @"1";

        NSTimeInterval locationLastUpdatedMillis = [[NSDate date] timeIntervalSinceDate:bestLocation.timestamp] * 1000.0;
        locationDict[kLocationLastUpdatedMilliseconds] = [NSString stringWithFormat:@"%.0f", locationLastUpdatedMillis];
    }

    return locationDict;
}

@end

@implementation MPAdServerURLBuilder (Open)

+ (MPURL *)conversionTrackingURLForAppID:(NSString *)appID {
    return [self openEndpointURLWithIDParameter:appID isSessionTracking:NO];
}

+ (MPURL *)sessionTrackingURL {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return [self openEndpointURLWithIDParameter:bundleIdentifier isSessionTracking:YES];
}

+ (MPURL *)openEndpointURLWithIDParameter:(NSString *)idParameter isSessionTracking:(BOOL)isSessionTracking {
    NSMutableDictionary * queryParameters = [self baseParametersDictionaryWithIDParameter:idParameter];

    // OPTIONAL: Include Session Tracking Parameter if needed
    if (isSessionTracking) {
        queryParameters[kOpenEndpointSessionTrackingKey] = @"1";
    }

    return [self URLWithComponents:MPAPIEndpoints.openURLComponents postData:queryParameters];
}

@end

@implementation MPAdServerURLBuilder (Consent)

#pragma mark - Consent URLs

+ (MPURL *)consentSynchronizationUrl {
    MPConsentManager * manager = MPConsentManager.sharedManager;

    // REQUIRED: Ad unit ID for consent may be empty if the publisher
    // never initialized the SDK.
    NSMutableDictionary * postData = [self baseParametersDictionaryWithIDParameter:manager.adUnitIdUsedForConsent];

    // OPTIONAL: Cached IFA used for consent, if available.
    postData[kCachedIfaForConsentKey] = manager.ifaForConsent;

    // OPTIONAL: Last synchronized consent status, last changed reason,
    // last changed timestamp in milliseconds
    postData[kLastSynchronizedConsentStatusKey] = manager.lastSynchronizedStatus;
    postData[kConsentChangedReasonKey] = manager.lastChangedReason;
    postData[kLastChangedMsKey] = manager.lastChangedTimestampInMilliseconds > 0 ? [NSString stringWithFormat:@"%llu", (unsigned long long)manager.lastChangedTimestampInMilliseconds] : nil;

    // OPTIONAL: Cached IAB Vendor List Hash Key
    postData[kCachedIabVendorListHashKey] = manager.iabVendorListHash;

    // OPTIONAL: Server extras
    postData[kExtrasKey] = manager.extras;

    // OPTIONAL: Force GDPR appliciability has changed
    postData[kForcedGDPRAppliesChangedKey] = manager.isForcedGDPRAppliesTransition ? @"1" : nil;

    return [self URLWithComponents:MPAPIEndpoints.consentSyncURLComponents postData:postData];
}

+ (MPURL *)consentDialogURL {
    MPConsentManager * manager = MPConsentManager.sharedManager;

    // REQUIRED: Ad unit ID for consent; may be empty if the publisher
    // never initialized the SDK.
    NSMutableDictionary * postData = [self baseParametersDictionaryWithIDParameter:manager.adUnitIdUsedForConsent];

    // REQUIRED: Language
    postData[kLanguageKey] = manager.currentLanguageCode;

    return [self URLWithComponents:MPAPIEndpoints.consentDialogURLComponents postData:postData];
}

@end

@implementation MPAdServerURLBuilder (Native)

+ (MPURL *)nativePositionUrlForAdUnitId:(NSString *)adUnitId {
    // No ad unit ID
    if (adUnitId == nil) {
        return nil;
    }

    NSDictionary * queryItems = [self baseParametersDictionaryWithIDParameter:adUnitId];
    return [self URLWithComponents:MPAPIEndpoints.nativePositioningURLComponents postData:queryItems];
}

@end

@implementation MPAdServerURLBuilder (Rewarded)

+ (MPURL *)rewardedCompletionUrl:(NSString *)sourceUrl
                  withCustomerId:(NSString *)customerId
                      rewardType:(NSString *)rewardType
                    rewardAmount:(NSNumber *)rewardAmount
                adapterClassName:(NSString *)adapterClassName
                  additionalData:(NSString *)additionalData {

    NSURLComponents * components = [NSURLComponents componentsWithString:sourceUrl];

    // Build the additional query parameters to be appended to the existing set.
    NSMutableDictionary<NSString *, NSString *> * postData = [NSMutableDictionary dictionary];

    // REQUIRED: Rewarded APIVersion
    postData[kServerAPIVersionKey] = MP_REWARDED_API_VERSION;

    // REQUIRED: SDK Version
    postData[kSDKVersionKey] = MP_SDK_VERSION;

    // OPTIONAL: Customer ID
    if (customerId != nil && customerId.length > 0) {
        postData[kCustomerIdKey] = customerId;
    }

    // OPTIONAL: Rewarded currency and amount
    if (rewardType != nil && rewardType.length > 0 && rewardAmount != nil) {
        postData[kRewardedCurrencyNameKey] = rewardType;
        postData[kRewardedCurrencyAmountKey] = [NSString stringWithFormat:@"%i", rewardAmount.intValue];
    }

    // OPTIONAL: Rewarded adapter name
    if (adapterClassName != nil) {
        postData[kRewardedAdapterClassNameKey] = adapterClassName;
    }

    // OPTIONAL: Additional publisher data
    if (additionalData != nil) {
        postData[kRewardedCustomDataKey] = additionalData;
    }

    return [MPURL URLWithComponents:components postData:postData];
}

@end

@implementation MPAdServerURLBuilder (SKAdNetwork)

+ (MPURL *)skAdNetworkSynchronizationURLWithSkAdNetworkIds:(NSArray <NSString *> *)skAdNetworkIds {
    if (skAdNetworkIds.count == 0) {
        return nil;
    }

    // Get URL components
    NSURLComponents * components = MPAPIEndpoints.skAdNetworkSyncURLComponents;

    // Get base parameters dictionary
    NSMutableDictionary <NSString *, __kindof NSObject *> * queryParameters = [self baseParametersDictionary];

    // Append supported networks to base parameters
    queryParameters[kSKAdNetworkSupportedNetworksKey] = skAdNetworkIds;

    // Return URL with post data
    return [MPURL URLWithComponents:components postData:queryParameters];
}

@end
