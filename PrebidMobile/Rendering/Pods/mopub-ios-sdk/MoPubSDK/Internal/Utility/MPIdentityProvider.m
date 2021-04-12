//
//  MPIdentityProvider.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <AdSupport/AdSupport.h>

#import "MPConsentManager.h"
#import "MPIdentityProvider.h"

// NSUserDefaults keys
static NSString *const kCachedMoPubIdentifierKey                 = @"com.mopub.identifier";

// Deprecated constants used to clean up NSUserDefaults in an upgrade scenario.
// These were deprecated as of version 5.14.0
static NSString *const kDeprecatedMoPubIdentifierLastSetKey      = @"com.mopub.identifiertime";
static NSString *const kDeprecatedMoPubPrefixToRemove            = @"mopub:";

// App Tracking Transparency value strings
NSString *const kAppTrackingTransparencyDescriptionAuthorized    = @"authorized";
NSString *const kAppTrackingTransparencyDescriptionDenied        = @"denied";
NSString *const kAppTrackingTransparencyDescriptionRestricted    = @"restricted";
NSString *const kAppTrackingTransparencyDescriptionNotDetermined = @"not_determined";

@implementation MPIdentityProvider

+ (BOOL)advertisingTrackingEnabled {
    if (@available(iOS 14.0, *)) {
        /*
         As of iOS 14, Apple does not provide an explicit means of checking if the IDFA is available.
         The IDFA may or may not be available with an ATT status of NotDetermined, depending on if
         Apple has decided to enforce ATT as opt-in as they plan to. Therefore, if the ATT status
         is NotDetermined, use the IDFA itself to work out the return value of this method.

         @c MPConsentManager depends on this method to detect DoNotTrack consent status. Given that,
         if this method were to use the @c ifa getter to grab the IDFA, which checks @c MPConsentManager
         to verify if IDFA is allowed to be collected, any GDPR status other than explicit_yes, combined
         with a "not_determined" ATT status, would result in @c MPConsentManager mistakenly locking into
         a DNT state. Therefore, check @c MPConsentManager's @c rawIfa value directly. Note that
         we are only checking if the IDFA is non-nil; IDFA is not collected here and should not ever
         be collected via any means besides the @c ifa getter below (minus special circumstances
         internal to @c MPConsentManager).
        */
        return self.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusAuthorized ||
            (self.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusNotDetermined && MPConsentManager.sharedManager.rawIfa != nil);
    }

    return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

+ (NSString *)ifa {
    MPConsentManager *consentManager = MPConsentManager.sharedManager;

    /*
     Regardless of if @c advertisingTrackingEnabled returns @c YES, provided that @c canCollectPersonalInfo
     is @c YES, go ahead and collect the IDFA if it's available. This ensures that even if APIs change in
     the future, the IDFA will always be included when available. iOS will restrict access when it is not
     available.
    */
    if (consentManager.canCollectPersonalInfo) {
        return consentManager.rawIfa;
    }

    return nil;
}

+ (NSString *)ifv {
    return UIDevice.currentDevice.identifierForVendor.UUIDString;
}

+ (NSString *)mopubId {
    // Generate the MoPub ID if it doesn't exist.
    NSString *identifier = [NSUserDefaults.standardUserDefaults objectForKey:kCachedMoPubIdentifierKey];
    if (identifier == nil) {
        identifier = NSUUID.UUID.UUIDString.uppercaseString;
        [NSUserDefaults.standardUserDefaults setObject:identifier forKey:kCachedMoPubIdentifierKey];
    }

    // Upgrade previous MoPub IDs which had the mopub: prefix and remove it.
    // Also remove the previous timestamp since it is no longer relevant.
    if ([identifier hasPrefix:kDeprecatedMoPubPrefixToRemove]) {
        identifier = [identifier substringFromIndex:kDeprecatedMoPubPrefixToRemove.length];
        [NSUserDefaults.standardUserDefaults setObject:identifier forKey:kCachedMoPubIdentifierKey];
        [NSUserDefaults.standardUserDefaults removeObjectForKey:kDeprecatedMoPubIdentifierLastSetKey];
    }

    return identifier;
}

+ (ATTrackingManagerAuthorizationStatus)trackingAuthorizationStatus {
    return ATTrackingManager.trackingAuthorizationStatus;
}

+ (NSString *)trackingAuthorizationStatusDescription {
    // For iOS 14+, just convert the tracking authorization status to its description string
    if (@available(iOS 14.0, *)) {
        switch (self.trackingAuthorizationStatus) {
            case ATTrackingManagerAuthorizationStatusDenied:
                return kAppTrackingTransparencyDescriptionDenied;
            case ATTrackingManagerAuthorizationStatusAuthorized:
                return kAppTrackingTransparencyDescriptionAuthorized;
            case ATTrackingManagerAuthorizationStatusRestricted:
                return kAppTrackingTransparencyDescriptionRestricted;
            case ATTrackingManagerAuthorizationStatusNotDetermined:
                return kAppTrackingTransparencyDescriptionNotDetermined;
            default:
                assert(NO); // Should never reach this point
                return nil;
        }
    }

    // For iOS 13-, convert DNT status to authorized/denied
    if (self.advertisingTrackingEnabled) {
        return kAppTrackingTransparencyDescriptionAuthorized;
    }
    else {
        return kAppTrackingTransparencyDescriptionDenied;
    }
}

@end
