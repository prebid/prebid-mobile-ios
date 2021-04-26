//
//  PBMGender.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMGender.h"

PBMGenderDescription const PBMGenderDescriptionUnknown = nil;
PBMGenderDescription const PBMGenderDescriptionMale = @"M";
PBMGenderDescription const PBMGenderDescriptionFemale = @"F";
PBMGenderDescription const PBMGenderDescriptionOther = @"O";

PBMGender pbmGenderFromDescription(PBMGenderDescription genderDescription) {
    if ([genderDescription isEqualToString:PBMGenderDescriptionMale]) {
        return PBMGenderMale;
    } else if ([genderDescription isEqualToString:PBMGenderDescriptionFemale]) {
        return PBMGenderFemale;
    } else if ([genderDescription isEqualToString:PBMGenderDescriptionOther]) {
        return PBMGenderOther;
    } else {
        return PBMGenderUnknown;
    }
}

PBMGenderDescription pbmDescriptionOfGender(PBMGender gender) {
    switch (gender) {
        case PBMGenderMale:
            return PBMGenderDescriptionMale;
        case PBMGenderFemale:
            return PBMGenderDescriptionFemale;
        case PBMGenderOther:
            return PBMGenderDescriptionOther;
            
        default:
            return PBMGenderDescriptionUnknown;
    }
}
