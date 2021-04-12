//
//  MPLocationAuthorizationStatus.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPLocationAuthorizationStatus.h"

NSString * _Nullable NSStringFromMPLocationAuthorizationStatus(MPLocationAuthorizationStatus status) {
    switch (status) {
        case kMPLocationAuthorizationStatusNotDetermined: return @"unknown";
        case kMPLocationAuthorizationStatusRestricted: return @"restricted";
        case kMPLocationAuthorizationStatusUserDenied: return @"user-denied";
        case kMPLocationAuthorizationStatusSettingsDenied: return @"system-denied";
        case kMPLocationAuthorizationStatusPublisherDenied: return @"publisher-denied";
        case kMPLocationAuthorizationStatusAuthorizedAlways: return @"authorized-always";
        case kMPLocationAuthorizationStatusAuthorizedWhenInUse: return @"authorized-while-in-use";
        default: return nil;
    }
}
