//
//  PBMGender.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBMGender) {
    PBMGenderUnknown,
    PBMGenderMale,
    PBMGenderFemale,
    PBMGenderOther
};

typedef NSString * PBMGenderDescription NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT PBMGenderDescription const PBMGenderDescriptionUnknown;
FOUNDATION_EXPORT PBMGenderDescription const PBMGenderDescriptionMale;
FOUNDATION_EXPORT PBMGenderDescription const PBMGenderDescriptionFemale;
FOUNDATION_EXPORT PBMGenderDescription const PBMGenderDescriptionOther;

FOUNDATION_EXPORT PBMGender pbmGenderFromDescription(PBMGenderDescription genderDescription);
FOUNDATION_EXPORT PBMGenderDescription pbmDescriptionOfGender(PBMGender gender);
