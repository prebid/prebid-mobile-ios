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

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMViewExposure : NSObject

/// Fration of area, visible to the user, in relative units (0...1)
@property (nonatomic, assign, readonly) float exposureFactor;
/// Fration of area, visible to the user, in % (0...100)
@property (nonatomic, assign, readonly) float exposedPercentage;
/// Bounding box of all fragments, visible to the user
@property (nonatomic, assign, readonly) CGRect visibleRectangle;
/// An array of non-intersecting obstruction rectangles (boxed CGRect values), sorted from largest to smallest area
@property (nonatomic, strong, nullable, readonly) NSArray<NSValue *> *occlusionRectangles;

/// Completely obstructed exposure -- exposedArea: 0, visibleRect: CGRectZero, occlusionRectangles: nil
@property (class, nonatomic, strong, readonly) PBMViewExposure *zeroExposure NS_SWIFT_NAME(zero);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithExposureFactor:(float)exposureFactor
                      visibleRectangle:(CGRect)visibleRectangle
                   occlusionRectangles:(nullable NSArray<NSValue *> *)occlusionRectangles NS_DESIGNATED_INITIALIZER;

/// Formatted string for passing as a parameter to mraid.js
- (NSString *)serializeWithFormatter:(NSNumberFormatter *)numberFormatter;

@end

NS_ASSUME_NONNULL_END
