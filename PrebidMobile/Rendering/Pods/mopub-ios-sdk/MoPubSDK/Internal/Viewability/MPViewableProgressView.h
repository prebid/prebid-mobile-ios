//
//  MPViewableProgressView.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPViewabilityObstruction.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPViewableProgressView : UIProgressView <MPViewabilityObstruction>

#pragma mark - MPViewabilityObstruction

/**
 The type of obstruction that this view identifies as.
 */
@property (nonatomic, readonly) MPViewabilityObstructionType viewabilityObstructionType;

/**
 A human-readable name that succinctly describes this obstruction.
 */
@property (nonatomic, copy, readonly) MPViewabilityObstructionName viewabilityObstructionName;

@end

NS_ASSUME_NONNULL_END
