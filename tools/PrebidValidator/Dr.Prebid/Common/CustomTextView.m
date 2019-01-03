//
//  CustomTextView.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 1/3/19.
//  Copyright © 2019 Prebid. All rights reserved.
//

#import "CustomTextView.h"

@implementation CustomTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(cut:) || action == @selector(paste:))
        return NO;
    return [super canPerformAction:action withSender:sender];
}

@end
