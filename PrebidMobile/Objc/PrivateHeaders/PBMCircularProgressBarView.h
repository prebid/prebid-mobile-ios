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

@interface PBMCircularProgressBarView : UIView

// Should show value string
@property (nonatomic,assign)  BOOL      showValueString;
@property (nonatomic,assign)  CGFloat   value;

// The name of the font of the value string
@property (nonatomic,copy)    NSString  *valueFontName;

// The maximum possible value, used to calculate the progress (value/maxValue)	[0,∞)
@property (nonatomic,assign)  CGFloat   maxValue;

// Padding from borders
@property (nonatomic,assign)  CGFloat borderPadding;

// The font size of the value text    [0,∞)
@property (nonatomic,assign)  CGFloat   valueFontSize;

// The color of the value and unit text
@property (nonatomic,strong)  UIColor   *fontColor;

// Progress bar rotation (Clockewise)    [0,100]
@property (nonatomic,assign)  CGFloat   progressRotationAngle;

// Set a partial angle for the progress bar    [0,100]
@property (nonatomic,assign)  CGFloat   progressAngle;

// The width of the progress bar (user space units)    [0,∞)
@property (nonatomic,assign)  CGFloat   progressLineWidth;

// The width of the empty space between progress line and end of background    [0,∞)
@property (nonatomic, assign) CGFloat   progressLinePadding;

// The color of the progress bar
@property (nonatomic,strong)  UIColor   *progressColor;

// The width of the background bar (user space units)    [0,∞)
@property (nonatomic,assign)  CGFloat   emptyLineWidth;

// The color of the background bar
@property (nonatomic,strong)  UIColor   *emptyLineColor;

// The color of the background bar stroke color
@property (nonatomic,strong)  UIColor   *emptyLineStrokeColor;

// The shape of the background bar cap    {kCGLineCapButt=0, kCGLineCapRound=1, kCGLineCapSquare=2}
@property (nonatomic,assign)  NSInteger emptyCapType;

// The offset to apply to the unit / value text
@property (nonatomic,assign)  CGPoint textOffset;

// The bool value to apply to if its counddown or not
@property (nonatomic,assign)  BOOL      countdown;

// The current value of progress
@property (nonatomic,assign) CGFloat duration;

- (void) updateProgress: (CGFloat) value;

@end
