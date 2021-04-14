//
//  OXAGender.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXAGender) {
    OXAGenderUnknown,
    OXAGenderMale,
    OXAGenderFemale,
    OXAGenderOther
};

typedef NSString * OXAGenderDescription NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT OXAGenderDescription const OXAGenderDescriptionUnknown;
FOUNDATION_EXPORT OXAGenderDescription const OXAGenderDescriptionMale;
FOUNDATION_EXPORT OXAGenderDescription const OXAGenderDescriptionFemale;
FOUNDATION_EXPORT OXAGenderDescription const OXAGenderDescriptionOther;

FOUNDATION_EXPORT OXAGender oxaGenderFromDescription(OXAGenderDescription genderDescription);
FOUNDATION_EXPORT OXAGenderDescription oxaDescriptionOfGender(OXAGender gender);
