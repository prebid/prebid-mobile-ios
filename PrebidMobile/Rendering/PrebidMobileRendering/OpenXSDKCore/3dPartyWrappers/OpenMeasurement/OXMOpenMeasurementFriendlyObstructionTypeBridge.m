//
//  OXMOpenMeasurementFriendlyObstructionTypeBridge.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMOpenMeasurementFriendlyObstructionTypeBridge.h"

@implementation OXMOpenMeasurementFriendlyObstructionTypeBridge

+ (OMIDFriendlyObstructionType)obstructionTypeOfObstructionPurpose:(OXMOpenMeasurementFriendlyObstructionPurpose)friendlyObstructionPurpose {
    switch (friendlyObstructionPurpose) {
        case OXMOpenMeasurementFriendlyObstructionModalViewControllerClose:
            return OMIDFriendlyObstructionCloseAd;
        case OXMOpenMeasurementFriendlyObstructionVideoViewProgressBar:
            return OMIDFriendlyObstructionMediaControls;
        default:
            return OMIDFriendlyObstructionOther;
    }
}

+ (NSString *)describeFriendlyObstructionPurpose:(OXMOpenMeasurementFriendlyObstructionPurpose)friendlyObstructionPurpose {
    
    // Can be nil.
    // If not nil, must be 50 characters or less and only contain characers
    // * `A-z`, `0-9`, or spaces.
    
    switch (friendlyObstructionPurpose) {
        case OXMOpenMeasurementFriendlyObstructionWindowLockerBackground:
            return @"Fullscreen UI locker or loading the ad";
        case OXMOpenMeasurementFriendlyObstructionWindowLockerActivityIndicator:
            return @"Activity Indicator for loading the ad";
        case OXMOpenMeasurementFriendlyObstructionLegalButtonDecorator:
            return @"Ad Choices button";
        case OXMOpenMeasurementFriendlyObstructionModalViewControllerView:
            return @"Fullscreen modal ad view container";
        case OXMOpenMeasurementFriendlyObstructionModalViewControllerClose:
            return @"Close button";
        case OXMOpenMeasurementFriendlyObstructionVideoViewLearnMoreButton:
            return @"Learn More  button";
        case OXMOpenMeasurementFriendlyObstructionVideoViewProgressBar:
            return @"Video playback Progress Bar";
        default:
            return nil;
    }
}

@end
