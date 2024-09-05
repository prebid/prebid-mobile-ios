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

/// An enumeration representing gender options for ad targeting or other purposes.
/// This enum is used to specify different gender options and is intended for use in contexts where gender information may be relevant.
///
/// - `unknown`: Gender is not specified or unknown.
/// - `male`: Represents the male gender.
/// - `female`: Represents the female gender.
/// - `other`: Represents any other gender that does not fit into the male or female categories.
@objc(PBMGender)
public enum Gender : Int {
    
    /// Gender is not specified or unknown.
    case unknown
    
    /// Represents the male gender.
    case male
    
    /// Represents the female gender.
    case female
    
    /// Represents any other gender that does not fit into the male or female categories.
    case other
}

enum GenderDescription : String {
    case male       = "M"
    case female     = "F"
    case other      = "O"
}

@available(*, deprecated, message: "Deprecated by ORTB")
func GenderFromDescription(_ genderDescription: String) -> Gender {
    guard let knownGender = GenderDescription(rawValue: genderDescription) else {
        return .unknown
    }
    
    switch knownGender {
        case .male:      return .male
        case .female:    return .female
        case .other:     return .other
    }
}

@available(*, deprecated, message: "Deprecated by ORTB")
func DescriptionOfGender(_ gender: Gender) -> String? {
    switch gender {
        case .unknown:   return nil
        case .male:      return GenderDescription.male.rawValue
        case .female:    return GenderDescription.female.rawValue
        case .other:     return GenderDescription.other.rawValue
    }
}

