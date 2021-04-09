//
//  MPViewableProgressView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPViewableProgressView.h"

@implementation MPViewableProgressView

- (MPViewabilityObstructionType)viewabilityObstructionType {
    return MPViewabilityObstructionTypeMediaControls;
}

- (MPViewabilityObstructionName)viewabilityObstructionName {
    return MPViewabilityObstructionNameProgressBar;
}

@end
