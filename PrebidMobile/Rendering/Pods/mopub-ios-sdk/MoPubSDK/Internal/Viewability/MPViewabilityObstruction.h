//
//  MPViewabilityObstruction.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPViewabilityObstructionName.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Type of Viewability obstruction.
 */
typedef NS_ENUM(NSUInteger, MPViewabilityObstructionType) {
    /**
     The obstruction relates to interacting with a video (such as play/pause buttons).
    */
    MPViewabilityObstructionTypeMediaControls,

    /**
     The obstruction relates to closing an ad (such as a close button).
     */
    MPViewabilityObstructionTypeClose,
    
    /**
     The obstruction is not visibly obstructing the ad but may seem so due to technical limitations.
     */
    MPViewabilityObstructionTypeNotVisible,
    
    /**
     The obstruction is obstructing for any purpose not already described.
     */
    MPViewabilityObstructionTypeOther
};

/**
 Describes a conforming object as a valid friendly obstruction for Viewability measurement.
 */
@protocol MPViewabilityObstruction <NSObject>

/**
 The type of obstruction that this view identifies as.
 */
@property (nonatomic, readonly) MPViewabilityObstructionType viewabilityObstructionType;

/**
 A human-readable name that succinctly describes this obstruction. For convenience, use only the
 predefined constants in `MPViewabilityObstructionName`.
 */
@property (nonatomic, copy, readonly) MPViewabilityObstructionName viewabilityObstructionName;

@end

NS_ASSUME_NONNULL_END
