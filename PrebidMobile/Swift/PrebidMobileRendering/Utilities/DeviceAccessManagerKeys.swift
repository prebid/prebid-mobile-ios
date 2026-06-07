/*   Copyright 2018-2021 Prebid.org, Inc.

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

import Foundation

@objc(PBMDeviceAccessManagerKeys)
public class DeviceAccessManagerKeys: NSObject {
    @objc public static let DESCRIPTION  = "description"
    @objc public static let LOCATION     = "location"
    @objc public static let RECURRENCE   = "recurrence"
    @objc public static let START        = "start"
    @objc public static let END          = "end"
    @objc public static let EXPIRES      = "expires"
    @objc public static let INTERVAL     = "interval"
    @objc public static let SUMMARY      = "summary"
    @objc public static let REMINDER     = "reminder"
    @objc public static let TRANSPARENCY = "freebusy"
    @objc public static let TRANSPARENT  = "transparent"
    @objc public static let FREQUENCY    = "frequency"
    @objc public static let DAILY        = "daily"
    @objc public static let WEEKLY       = "weekly"
    @objc public static let MONTHLY      = "monthly"
    @objc public static let DAYS_IN_WEEK  = "daysInWeek"
    @objc public static let DAYS_IN_MONTH = "daysInMonth"
    @objc public static let DAYS_IN_YEAR  = "daysInYear"
    @objc public static let MONTHS_IN_YEAR = "monthsInYear"
}
