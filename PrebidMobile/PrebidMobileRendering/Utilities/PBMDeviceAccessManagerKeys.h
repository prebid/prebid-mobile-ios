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

#import <Foundation/Foundation.h>

@interface PBMDeviceAccessManagerKeys : NSObject

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

