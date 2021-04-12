//
//  MPViewableButton.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPExtendedHitBoxButton.h"
#import "MPViewabilityObstruction.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPViewableButton : MPExtendedHitBoxButton <MPViewabilityObstruction>

+ (instancetype)buttonWithType:(UIButtonType)buttonType
               obstructionType:(MPViewabilityObstructionType)obstructionType
               obstructionName:(MPViewabilityObstructionName)obstructionName;

#pragma mark - MPViewabilityObstruction

/**
 The type of obstruction that this view identifies as.
 */
@property (nonatomic, readonly) MPViewabilityObstructionType viewabilityObstructionType;

/**
 A human-readable name that succinctly describes this obstruction.
 */
@property (nonatomic, copy, readonly) MPViewabilityObstructionName viewabilityObstructionName;

#pragma mark - Unavailable

+ (instancetype)buttonWithType:(UIButtonType)buttonType NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
