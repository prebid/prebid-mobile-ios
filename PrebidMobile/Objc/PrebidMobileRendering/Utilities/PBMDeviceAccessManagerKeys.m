/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMDeviceAccessManagerKeys.h"

@implementation PBMDeviceAccessManagerKeys

+ (nonnull NSString *)DESCRIPTION {
    return  @"description";
}
+ (nonnull NSString *)LOCATION {
    return @"location";
}

+ (nonnull NSString *)RECURRENCE {
    return @"recurrence";
}

+ (nonnull NSString *)START {
    return @"start";
}

+ (nonnull NSString *)END {
    return @"end";
}

+ (nonnull NSString *)EXPIRES {
    return @"expires";
}

+ (nonnull NSString *)INTERVAL {
    return @"interval";
}

+ (nonnull NSString *)SUMMARY {
    return @"summary";
}

+ (nonnull NSString *)REMINDER {
    return @"reminder";
}

+ (nonnull NSString *)TRANSPARENCY {
    return @"freebusy";
}

+ (nonnull NSString *)TRANSPARENT {
    return @"transparent";
}

+ (nonnull NSString *)FREQUENCY {
    return @"frequency";
}

+ (nonnull NSString *)DAILY {
    return @"daily";
}

+ (nonnull NSString *)WEEKLY {
    return @"weekly";
}

+ (nonnull NSString *)MONTHLY {
    return @"monthly";
}

+ (nonnull NSString *)DAYS_IN_WEEK {
    return @"daysInWeek";
}

+ (nonnull NSString *)DAYS_IN_MONTH {
    return @"daysInMonth";
}

+ (nonnull NSString *)DAYS_IN_YEAR {
    return @"daysInYear";
}

+ (nonnull NSString *)MONTHS_IN_YEAR {
    return @"monthsInYear";
}


@end

