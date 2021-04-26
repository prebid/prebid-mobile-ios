//
//  PBMTouchDownRecognizer.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "PBMTouchDownRecognizer.h"

@implementation PBMTouchDownRecognizer

//If a touch *begins* on the view, that counts as a succesful touchDown.
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

@end
