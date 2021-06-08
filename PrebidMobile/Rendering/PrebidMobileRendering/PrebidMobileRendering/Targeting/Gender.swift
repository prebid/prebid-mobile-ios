//
//  Gender.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public enum Gender : Int {
    case unknown
    case male
    case female
    case other
}

enum GenderDescription : String {
    case male       = "M"
    case female     = "F"
    case other      = "O"
}


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

func DescriptionOfGender(_ gender: Gender) -> String? {
    switch gender {
        case .unknown:   return nil
        case .male:      return GenderDescription.male.rawValue
        case .female:    return GenderDescription.female.rawValue
        case .other:     return GenderDescription.other.rawValue
    }
}

