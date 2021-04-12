//
//  OXMDeviceAccessManagerKeys.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OXMDeviceAccessManagerKeys : NSObject

@property (class, readonly, nonnull) NSString *DESCRIPTION;
@property (class, readonly, nonnull) NSString *LOCATION;
@property (class, readonly, nonnull) NSString *RECURRENCE;

@property (class, readonly, nonnull) NSString *START;
@property (class, readonly, nonnull) NSString *END;
@property (class, readonly, nonnull) NSString *EXPIRES;
@property (class, readonly, nonnull) NSString *INTERVAL;

@property (class, readonly, nonnull) NSString *SUMMARY;
@property (class, readonly, nonnull) NSString *REMINDER;

@property (class, readonly, nonnull) NSString *TRANSPARENCY;
@property (class, readonly, nonnull) NSString *TRANSPARENT;
@property (class, readonly, nonnull) NSString *FREQUENCY;

@property (class, readonly, nonnull) NSString *DAILY;
@property (class, readonly, nonnull) NSString *WEEKLY;
@property (class, readonly, nonnull) NSString *MONTHLY;

@property (class, readonly, nonnull) NSString *DAYS_IN_WEEK;
@property (class, readonly, nonnull) NSString *DAYS_IN_MONTH;
@property (class, readonly, nonnull) NSString *DAYS_IN_YEAR;
@property (class, readonly, nonnull) NSString *MONTHS_IN_YEAR;

@end

