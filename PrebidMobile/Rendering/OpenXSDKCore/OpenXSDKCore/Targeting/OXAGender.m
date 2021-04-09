//
//  OXAGender.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAGender.h"

OXAGenderDescription const OXAGenderDescriptionUnknown = nil;
OXAGenderDescription const OXAGenderDescriptionMale = @"M";
OXAGenderDescription const OXAGenderDescriptionFemale = @"F";
OXAGenderDescription const OXAGenderDescriptionOther = @"O";

OXAGender oxaGenderFromDescription(OXAGenderDescription genderDescription) {
    if ([genderDescription isEqualToString:OXAGenderDescriptionMale]) {
        return OXAGenderMale;
    } else if ([genderDescription isEqualToString:OXAGenderDescriptionFemale]) {
        return OXAGenderFemale;
    } else if ([genderDescription isEqualToString:OXAGenderDescriptionOther]) {
        return OXAGenderOther;
    } else {
        return OXAGenderUnknown;
    }
}

OXAGenderDescription oxaDescriptionOfGender(OXAGender gender) {
    switch (gender) {
        case OXAGenderMale:
            return OXAGenderDescriptionMale;
        case OXAGenderFemale:
            return OXAGenderDescriptionFemale;
        case OXAGenderOther:
            return OXAGenderDescriptionOther;
            
        default:
            return OXAGenderDescriptionUnknown;
    }
}
