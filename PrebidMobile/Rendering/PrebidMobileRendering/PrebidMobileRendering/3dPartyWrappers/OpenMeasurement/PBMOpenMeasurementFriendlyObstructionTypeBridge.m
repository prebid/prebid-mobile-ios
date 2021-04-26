//
//  PBMOpenMeasurementFriendlyObstructionTypeBridge.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMOpenMeasurementFriendlyObstructionTypeBridge.h"

@implementation PBMOpenMeasurementFriendlyObstructionTypeBridge

+ (OMIDFriendlyObstructionType)obstructionTypeOfObstructionPurpose:(PBMOpenMeasurementFriendlyObstructionPurpose)friendlyObstructionPurpose {
    switch (friendlyObstructionPurpose) {
        case PBMOpenMeasurementFriendlyObstructionModalViewControllerClose:
            return OMIDFriendlyObstructionCloseAd;
        case PBMOpenMeasurementFriendlyObstructionVideoViewProgressBar:
            return OMIDFriendlyObstructionMediaControls;
        default:
            return OMIDFriendlyObstructionOther;
    }
}

+ (NSString *)describeFriendlyObstructionPurpose:(PBMOpenMeasurementFriendlyObstructionPurpose)friendlyObstructionPurpose {
    
    // Can be nil.
    // If not nil, must be 50 characters or less and only contain characers
    // * `A-z`, `0-9`, or spaces.
    
    switch (friendlyObstructionPurpose) {
        case PBMOpenMeasurementFriendlyObstructionWindowLockerBackground:
            return @"Fullscreen UI locker or loading the ad";
        case PBMOpenMeasurementFriendlyObstructionWindowLockerActivityIndicator:
            return @"Activity Indicator for loading the ad";
        case PBMOpenMeasurementFriendlyObstructionLegalButtonDecorator:
            return @"Ad Choices button";
        case PBMOpenMeasurementFriendlyObstructionModalViewControllerView:
            return @"Fullscreen modal ad view container";
        case PBMOpenMeasurementFriendlyObstructionModalViewControllerClose:
            return @"Close button";
        case PBMOpenMeasurementFriendlyObstructionVideoViewLearnMoreButton:
            return @"Learn More  button";
        case PBMOpenMeasurementFriendlyObstructionVideoViewProgressBar:
            return @"Video playback Progress Bar";
        default:
            return nil;
    }
}

@end
