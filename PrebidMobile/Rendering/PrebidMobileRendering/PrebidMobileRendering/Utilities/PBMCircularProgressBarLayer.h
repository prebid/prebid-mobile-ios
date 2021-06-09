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

@import QuartzCore;

/*
    The class is a CALayer subclass that represents the underlying layer
    of the containing view.
*/
@interface PBMCircularProgressBarLayer : CALayer

// Set a partial angle for the progress bar    [0,100]
@property (nonatomic, assign) CGFloat  progressAngle;

// Progress bar rotation (Clockewise)    [0,100]
@property (nonatomic, assign) CGFloat  progressRotationAngle;

// The value of the progress bar
@property (atomic, assign) CGFloat  value;

// The maximum possible value, used to calculate the progress (value/maxValue)    [0,∞)
@property (nonatomic, assign) CGFloat  maxValue;

// Animation duration in seconds
@property (nonatomic, assign) NSTimeInterval  animationDuration;

// The font size of the value text [0,∞)
@property (nonatomic, assign) CGFloat valueFontSize;

// The name of the font of the unit string
@property (nonatomic, assign) CGFloat unitFontSize;

// The color of the value and unit text
@property (nonatomic, strong) UIColor *fontColor;

// The width of the progress bar (user space units)    [0,∞)
@property (nonatomic, assign) CGFloat progressLineWidth;

// The color of the progress bar
@property (nonatomic, strong) UIColor *progressColor;

// The width of the background bar (user space units)    [0,∞)
@property (nonatomic, assign) CGFloat emptyLineWidth;

// The width of the empty space between progress line and end of background    [0,∞)
@property (nonatomic, assign) CGFloat progressLinePadding;

// The color of the background bar
@property (nonatomic, strong) UIColor *emptyLineColor;

// The color of the background bar stroke line
@property (nonatomic, strong) UIColor *emptyLineStrokeColor;

// The name of the font of the unit string
@property (nonatomic, copy) NSString *valueFontName;

// Should show value string
@property (nonatomic, assign)  BOOL showValueString;

// Show label value as countdown (default: NO);
@property (nonatomic, assign)  BOOL countdown;

@end
