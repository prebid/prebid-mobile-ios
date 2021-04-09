//
//  MPViewableButton.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPViewableButton.h"

@interface MPViewableButton()
@property (nonatomic, readwrite) MPViewabilityObstructionType viewabilityObstructionType;
@property (nonatomic, copy, readwrite) MPViewabilityObstructionName viewabilityObstructionName;
@end

@implementation MPViewableButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType
               obstructionType:(MPViewabilityObstructionType)obstructionType
               obstructionName:(MPViewabilityObstructionName)obstructionName {
    MPViewableButton *button = [super buttonWithType:buttonType];
    button.viewabilityObstructionType = obstructionType;
    button.viewabilityObstructionName = obstructionName;
    
    return button;
}

@end
