//
//  OXMViewExposure.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXMViewExposure : NSObject

/// Fration of area, visible to the user, in relative units (0...1)
@property (nonatomic, assign, readonly) float exposureFactor;
/// Fration of area, visible to the user, in % (0...100)
@property (nonatomic, assign, readonly) float exposedPercentage;
/// Bounding box of all fragments, visible to the user
@property (nonatomic, assign, readonly) CGRect visibleRectangle;
/// An array of non-intersecting obstruction rectangles (boxed CGRect values), sorted from largest to smallest area
@property (nonatomic, strong, nullable, readonly) NSArray<NSValue *> *occlusionRectangles;

/// Completely obstructed exposure -- exposedArea: 0, visibleRect: CGRectZero, occlusionRectangles: nil
@property (class, nonatomic, strong, readonly) OXMViewExposure *zeroExposure NS_SWIFT_NAME(zero);

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithExposureFactor:(float)exposureFactor
                      visibleRectangle:(CGRect)visibleRectangle
                   occlusionRectangles:(nullable NSArray<NSValue *> *)occlusionRectangles NS_DESIGNATED_INITIALIZER;

/// Formatted string for passing as a parameter to mraid.js
- (NSString *)serializeWithFormatter:(NSNumberFormatter *)numberFormatter;

@end

NS_ASSUME_NONNULL_END
