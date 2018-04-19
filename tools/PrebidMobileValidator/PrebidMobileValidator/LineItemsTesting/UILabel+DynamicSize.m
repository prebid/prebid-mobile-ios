//
//  UILabel+DynamicSize.m
//  PrebidMobileValidator
//
//  Created by Punnaghai Puviarasu on 4/18/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "UILabel+DynamicSize.h"

@implementation UILabel (DynamicSize)

-(float)resizeToFit{
    float height = [self expectedHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

-(float)expectedHeight{
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByCharWrapping];
    
    UIFont *font = [UIFont systemFontOfSize:14.0]; //Warning! It's an example, set the font, you need
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,9999);
    
    CGRect expectedLabelRect = [[self text] boundingRectWithSize:maximumLabelSize
                                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                      attributes:attributesDictionary
                                                         context:nil];
    CGSize *expectedLabelSize = &expectedLabelRect.size;
    
    return expectedLabelSize->height;
}

@end
