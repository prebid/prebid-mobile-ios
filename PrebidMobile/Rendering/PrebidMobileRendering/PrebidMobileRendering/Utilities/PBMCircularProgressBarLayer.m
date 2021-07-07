/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

@import UIKit;
@import CoreGraphics;

#import "PBMCircularProgressBarLayer.h"

@implementation PBMCircularProgressBarLayer
@dynamic value;

#pragma mark - Drawing

- (void) drawInContext:(CGContextRef) context{
    [super drawInContext:context];
    
    UIGraphicsPushContext(context);
    
    CGRect rect = CGContextGetClipBoundingBox(context);

    [self setupBackgroundShape:rect];
    [self drawProgressBar:rect context:context];
  
    if (self.showValueString){
        [self drawText:rect];
    }
    
    UIGraphicsPopContext();
}

- (void)setupBackgroundShape:(CGRect)rect {
    CAShapeLayer *maskingShape = [CAShapeLayer new];
    maskingShape.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
    self.mask = maskingShape;
}

- (void)drawProgressBar:(CGRect)rect context:(CGContextRef)context{
    if (self.progressLineWidth <= 0) {
        return;
    }
    
    CGPoint center = { CGRectGetMidX(rect), CGRectGetMidY(rect) };
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat radius = MIN(width, height)/2;

    radius = radius - MAX(self.emptyLineWidth, self.progressLineWidth)/2.f;
    
    radius = radius - self.progressLinePadding;
    
    CGMutablePathRef arc = CGPathCreateMutable();
    CGPathAddArc(arc, NULL,
                 center.x, center.y, radius,
                 (self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI-(2.f*M_PI)*(self.progressAngle/100.f)*(100.f-100.f*self.value/self.maxValue)/100.f,
                 -(self.progressAngle/100.f)*M_PI-((-self.progressRotationAngle/100.f)*2.f+0.5)*M_PI,
                 YES);
    
    CGPathRef strokedArc = CGPathCreateCopyByStrokingPath(arc, NULL,
                                   self.progressLineWidth,
                                   (CGLineCap)kCGLineCapRound,
                                   kCGLineJoinMiter,
                                   10);

    CGContextAddPath(context, strokedArc);
    CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.progressColor.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGPathRelease(arc);
    CGPathRelease(strokedArc);
}

- (void)drawText:(CGRect)rect {
    // if the value is less than 1 (i.e. rounds down to '0') don't draw the text.
    if (self.value <= 1) {
        return;
    }
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;

    CGFloat valueFontSize = self.valueFontSize == -1 ? CGRectGetHeight(rect)/5 : self.valueFontSize;

    UIFont *font = [UIFont systemFontOfSize: valueFontSize];
    NSDictionary* valueFontAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: self.fontColor, NSParagraphStyleAttributeName: textStyle};

    NSMutableAttributedString *text = [NSMutableAttributedString new];

    NSString *formatString = @"%.0f";
    NSString* textToPresent;
    
    // If counting down (i.e. going from 0 to 100, or 100 to 0), adjust displayed value appropriately.s
    if (self.countdown) {
        textToPresent = [NSString stringWithFormat:formatString, (self.maxValue - self.value)];
    }
    else {
        textToPresent = [NSString stringWithFormat:formatString, self.value];
    }
    NSAttributedString* value = [[NSAttributedString alloc] initWithString:textToPresent
                                                                attributes:valueFontAttributes];
    [text appendAttributedString:value];

    CGSize percentSize = [text size];
    CGPoint textCenter = CGPointMake( CGRectGetMidX(rect)-percentSize.width/2,
                                      CGRectGetMidY(rect)-percentSize.height/2 );
    [text drawAtPoint:textCenter];  
}

+ (BOOL)needsDisplayForKey: (NSString *)key {
    if ([key isEqualToString:@"value"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}
@end
