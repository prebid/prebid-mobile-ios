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


class DeviceAccessManagerKeys: NSObject {
    static let DESCRIPTION  = "description"
    static let LOCATION     = "location"
    static let RECURRENCE   = "recurrence"
    static let START        = "start"
    static let END          = "end"
    static let EXPIRES      = "expires"
    static let INTERVAL     = "interval"
    static let SUMMARY      = "summary"
    static let REMINDER     = "reminder"
    static let TRANSPARENCY = "freebusy"
    static let TRANSPARENT  = "transparent"
    static let FREQUENCY    = "frequency"
    static let DAILY        = "daily"
    static let WEEKLY       = "weekly"
    static let MONTHLY      = "monthly"
    static let DAYS_IN_WEEK  = "daysInWeek"
    static let DAYS_IN_MONTH = "daysInMonth"
    static let DAYS_IN_YEAR  = "daysInYear"
    static let MONTHS_IN_YEAR = "monthsInYear"
}
