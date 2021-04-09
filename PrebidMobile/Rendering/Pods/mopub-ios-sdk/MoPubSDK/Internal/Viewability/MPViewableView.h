//
//  MPViewableView.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPViewabilityObstruction.h"
#import "MPViewabilityTracker.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that denotes that the object is Viewable and provides Viewable information.
 */
@protocol MPViewable <NSObject>
/**
 All friend obstruction subviews. This will also aggregate subviews which contain friendly obstructions as well.
 If there are no friendly obstructions, this value will be  @c nil.
 */
@property (nonatomic, nullable, readonly) NSSet<UIView<MPViewabilityObstruction> *> *friendlyObstructions;

/**
 Optional weak reference to the Viewability tracker. This allows objects that conform to @c MPViewable to add additional
 friendly obstructions.
 */
@property (nonatomic, weak) id<MPViewabilityTracker> viewabilityTracker;

@end

/**
 Base class for UI elements that are expected to be viewable or contain viewable elements.
 */
@interface MPViewableView : UIView <MPViewable>

@end

NS_ASSUME_NONNULL_END
