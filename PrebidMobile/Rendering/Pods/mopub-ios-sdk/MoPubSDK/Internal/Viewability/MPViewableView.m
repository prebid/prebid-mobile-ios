//
//  MPViewableView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPViewableView.h"

@implementation MPViewableView

#pragma mark - Overrides

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    
    // No Viewability tracker to notify of potential friendly obstruction
    // changes.
    if (self.viewabilityTracker == nil) {
        return;
    }
    
    // View is a friendly obstruction
    if ([view conformsToProtocol:@protocol(MPViewabilityObstruction)]) {
        // Register the new view as a friendly obstruction
        UIView<MPViewabilityObstruction> *obstructionSubView = (UIView<MPViewabilityObstruction> *)view;
        [self.viewabilityTracker addFriendlyObstructions:[NSSet setWithObject:obstructionSubView]];
    }
    
    // View is Viewable
    if ([view conformsToProtocol:@protocol(MPViewable)]) {
        UIView<MPViewable> *viewableSubview = (UIView<MPViewable> *)view;
        
        // Set the new view's weak tracker reference to this tracker
        viewableSubview.viewabilityTracker = self.viewabilityTracker;
        
        // Register the new view's friendly obstructions
        [self.viewabilityTracker addFriendlyObstructions:viewableSubview.friendlyObstructions];
    }
}

#pragma mark - MPViewable

// Viewability tracker property from `MPViewable`.
@synthesize viewabilityTracker;

- (void)setViewabilityTracker:(id<MPViewabilityTracker>)tracker {
    // Set the backing property
    viewabilityTracker = tracker;
    
    // Update all `MPViewable` subviews of the tracker change.
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        // View is a friendly obstruction
        if ([subview conformsToProtocol:@protocol(MPViewabilityObstruction)]) {
            // Register the subview as a friendly obstruction with the new tracker
            UIView<MPViewabilityObstruction> *obstructionSubView = (UIView<MPViewabilityObstruction> *)subview;
            [tracker addFriendlyObstructions:[NSSet setWithObject:obstructionSubView]];
        }
        
        // View is Viewable
        if ([subview conformsToProtocol:@protocol(MPViewable)]) {
            UIView<MPViewable> *viewableSubview = (UIView<MPViewable> *)subview;
            
            // Set the new view's weak tracker reference to this tracker
            viewableSubview.viewabilityTracker = tracker;
            
            // Register the view's friendly obstructions with the new tracker
            [tracker addFriendlyObstructions:viewableSubview.friendlyObstructions];
        }
    }];
}

- (NSSet<UIView<MPViewabilityObstruction> *> * _Nullable)friendlyObstructions {
    // Resulting obstructions found.
    NSMutableSet<UIView<MPViewabilityObstruction> *> *obstructions = [NSMutableSet set];
    
    // Iterate over all subviews looking for friendly obstructions (conformance to `MPViewabilityObstruction`)
    // or views that are themselves viewable (conformance to `MPViewable`). Note that it is possible for a
    // view to be both `MPViewable` and `MPViewabilityObstruction`.
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        // Friendly obstruction
        if ([subview conformsToProtocol:@protocol(MPViewabilityObstruction)]) {
            UIView<MPViewabilityObstruction> *obstructionSubView = (UIView<MPViewabilityObstruction> *)subview;
            [obstructions addObject:obstructionSubView];
        }
        
        // Viewable
        if ([subview conformsToProtocol:@protocol(MPViewable)]) {
            UIView<MPViewable> *viewableSubview = (UIView<MPViewable> *)subview;
            NSSet<UIView<MPViewabilityObstruction> *> *subviewObstructions = viewableSubview.friendlyObstructions;
            if (subviewObstructions.count > 0) {
                [obstructions unionSet:subviewObstructions];
            }
        }
    }];
    
    return (obstructions.count > 0 ? obstructions : nil);
}

@end
