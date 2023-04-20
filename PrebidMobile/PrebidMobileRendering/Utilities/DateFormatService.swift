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

import Foundation

@objc(PBMDateFormatService) @objcMembers
public class DateFormatService: NSObject {
    
    // MARK: - Public properties
    
    public static let shared = DateFormatService()
    
    // MARK: - Private properties
    
    private var ISO8601FormatterUTC: DateFormatter {
        let formatter = DateFormatter()
        //Note that the single-quotes imply a string. ISO8601 dates do not have the quotes in them:
        //2015-07-30T02:26:54-0700
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    private var ISO8601FormatterMRAID: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    
    public func formatISO8601(for strDate: String?) -> Date? {
        guard let strDate = strDate, strDate.count >= 17 else {
            return nil
        }
        
        let delimeter = strDate[strDate.index(strDate.startIndex, offsetBy: 16)]
        
        if delimeter == ":" {
            //There is a seconds field. Use _ISO8601FormatterUTC
            return ISO8601FormatterUTC.date(from: strDate)
        }
        
        //No seconds field. Use _ISO8601FormatterMRAID
        return ISO8601FormatterMRAID.date(from: strDate)
    }
    
    private override init() {
        super.init()
    }
}
