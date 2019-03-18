/*   Copyright 2018-2019 Prebid.org, Inc.

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
import CoreLocation

@objc public enum Gender: Int {
    case unknown
    case male
    case female
}

@objcMembers public class Targeting: NSObject {

    private var yearofbirth: Int = 0

    /**
     * This property gets the gender enum passed set by the developer
     */

    public var gender: Gender

    public var yearOfBirth: Int {
        return yearofbirth
    }

    /**
     * This property gets the year of birth value set by the application developer
     */
    public func setYearOfBirth(yob: Int) throws {
        let date = Date()
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)

        if (yob <= 1900 || yob >= year) {
            throw ErrorCode.yearOfBirthInvalid
        } else {
            yearofbirth = yob
        }
    }

    /**
     * This property clears year of birth value set by the application developer
     */
    public func clearYearOfBirth() {
            yearofbirth = 0
    }

    /**
     * The itunes app id for targeting
     */
    public var itunesID: String?

    /**
     * The application location for targeting
     */
    public var location: CLLocation?

    /**
     * The application location precision for targeting
     */
    public var locationPrecision: Int?

    /**
     * The boolean value set by the user to collect user data
     */
    public var subjectToGDPR: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: .PB_GDPR_SubjectToConsent)
        }

        get {
            var gdprConsent: Bool = false

            if ((UserDefaults.standard.object(forKey: .PB_GDPR_SubjectToConsent)) != nil) {
                gdprConsent = UserDefaults.standard.bool(forKey: .PB_GDPR_SubjectToConsent)
            } else if ((UserDefaults.standard.object(forKey: .IAB_GDPR_SubjectToConsent)) != nil) {
                let stringValue: String = UserDefaults.standard.object(forKey: .IAB_GDPR_SubjectToConsent) as! String

                gdprConsent = Bool(stringValue)!
            }
            return gdprConsent
        }
    }

    /**
     * The consent string for sending the GDPR consent
     */
    public var gdprConsentString: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: .PB_GDPR_ConsentString)
        }

        get {
            let pbString: String? = UserDefaults.standard.object(forKey: .PB_GDPR_ConsentString) as? String
            let iabString: String? = UserDefaults.standard.object(forKey: .IAB_GDPR_ConsentString) as? String

            var savedConsent: String?
            if (pbString != nil) {
                savedConsent = pbString
            } else if (iabString != nil) {
                savedConsent = iabString
            }
            return savedConsent
        }
    }

    /**
     * The class is created as a singleton object & used
     */
    public static let shared = Targeting()

    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        gender = Gender.unknown
    }

}
