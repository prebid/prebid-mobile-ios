//
//  PBMTouchForwardingView.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMTouchForwardingView.h"

@implementation PBMTouchForwardingView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) {
        for (UIView* passthroughView in _passThroughViews) {
            hit = [passthroughView hitTest:[self convertPoint:point toView:passthroughView]
                                 withEvent:event];
            if (hit) {
                break;
            }
        }
    }
    return hit;
}

@end
