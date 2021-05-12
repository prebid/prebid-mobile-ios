//
//  MPViewableVisualEffectView.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPViewableVisualEffectView.h"

@implementation MPViewableVisualEffectView

#pragma mark - MPViewabilityObstruction

- (MPViewabilityObstructionType)viewabilityObstructionType {
    return MPViewabilityObstructionTypeOther;
}

- (MPViewabilityObstructionName)viewabilityObstructionName {
    return MPViewabilityObstructionNameBlur;
}

@end
