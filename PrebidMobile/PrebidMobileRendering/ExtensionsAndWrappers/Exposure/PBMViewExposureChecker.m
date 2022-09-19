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

#import "PBMViewExposureChecker.h"

#ifdef DEBUG
    #import "Prebid+TestExtension.h"
    #import "PrebidMobileSwiftHeaders.h"
    #if __has_include("PrebidMobile-Swift.h")
    #import "PrebidMobile-Swift.h"
    #else
    #import <PrebidMobile/PrebidMobile-Swift.h>
    #endif
#endif

@interface PBMViewExposureChecker()

@property (nonatomic, nullable, weak, readonly) UIView *testedView;
@property (nonatomic, assign, readwrite) CGRect clippedRect;
@property (nonatomic, nonnull, strong, readonly) NSMutableArray<NSValue *> *obstructions; // [CGRect]

@end

@implementation PBMViewExposureChecker

// MARK: - Public API

+ (PBMViewExposure *)exposureOfView:(UIView *)view {
    return [[[PBMViewExposureChecker alloc] initWithView:view] exposure];
}

- (instancetype)initWithView:(UIView *)view {
    if (!(self = [super init])) {
        return nil;
    }
    _testedView = view;
    _obstructions = [[NSMutableArray alloc] init];
    return self;
}

- (PBMViewExposure *)exposure {
    self.clippedRect = self.testedView.bounds;
    [self.obstructions removeAllObjects];
        
#   ifdef DEBUG
    if (Prebid.shared.forcedIsViewable) {
        return [[PBMViewExposure alloc] initWithExposureFactor:1 visibleRectangle:self.testedView.bounds occlusionRectangles:nil];
    }
#   endif
    
    if (!self.testedView || self.testedView.isHidden || self.testedView.superview == nil || ![self isOnForeground]) {
        return [PBMViewExposure zeroExposure];
    }
    
    BOOL potentiallyExposed = [self visitParent:self.testedView.superview fromChild:self.testedView] && [self collapseBoundingBox];
    if (!potentiallyExposed) {
        return [PBMViewExposure zeroExposure];
    }
    
    NSArray<NSValue *> * const obstructions = [self buildObstructionRects];
    CGSize const fullSize = self.testedView.bounds.size;
    float const fullArea = fullSize.width * fullSize.height;
    float const clipArea = self.clippedRect.size.width * self.clippedRect.size.height;
    float obstructedArea = 0;
    for(NSValue *rect in obstructions) {
        CGSize const nextSize = rect.CGRectValue.size;
        obstructedArea += nextSize.width * nextSize.height;
    }
    
    return [[PBMViewExposure alloc] initWithExposureFactor:(clipArea - obstructedArea)/fullArea
                                             visibleRectangle:self.clippedRect
                                          occlusionRectangles:obstructions];
}

// MARK: - Private API

- (BOOL)isOnForeground {
    UIWindow * const window = self.testedView.window;
    if (!window) {
        return NO;
    }
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return NO;
    }
    
    if (@available(iOS 13.0, *)) {
        return (window.windowScene != nil && window.windowScene.activationState == UISceneActivationStateForegroundActive);
    } else {
        return YES;
    }
}

// return 'NO' if exposure is zero
- (BOOL)visitParent:(UIView *)parentView fromChild:(UIView *)childView {
    if (parentView.isHidden) {
        return NO;
    }
    BOOL const clip = parentView.clipsToBounds || (parentView == self.testedView.window);
    if (clip) {
        self.clippedRect = CGRectIntersection(self.clippedRect, [self.testedView convertRect:parentView.bounds fromView:parentView]);
        if (CGRectIsEmpty(self.clippedRect)) {
            return NO;
        }
    }
    
    if (parentView.superview != nil) {
        BOOL notOverclipped = [self visitParent:parentView.superview fromChild:parentView];
        if (!notOverclipped) {
            return NO;
        }
    }
    
    NSArray<UIView *> *subViews = [parentView subviews];
    for(NSUInteger i = [subViews indexOfObject:childView] + 1, n = subViews.count; i < n; i++) {
        [self collectObstructionsFrom:subViews[i]];
    }
    return YES;
}

- (void)collectObstructionsFrom:(UIView *)view {
    if (view.isHidden) {
        return; // not obstructing
    }
    [self testForObstructing:view];
    if (view.clipsToBounds) {
        return; // do not check children
    }
    for(UIView *subView in [view subviews]) {
        [self collectObstructionsFrom:subView];
    }
}

// return 'YES' if resulted in non-empty rect
- (BOOL)collapseBoundingBox {
    CGRect const oldRect = self.clippedRect;
    if (CGRectIsEmpty(oldRect)) {
        return NO;
    }
    
    NSMutableArray<NSValue *> *currentRects = [[NSMutableArray alloc] init];
    NSMutableArray<NSValue *> *nextRects = [[NSMutableArray alloc] init];
    
    [currentRects addObject:@(self.clippedRect)];
    for(NSValue *obstruction in self.obstructions) {
        [self removeRect:obstruction.CGRectValue from:currentRects into:nextRects startingWith:0];
        
        // swap currentRects and nextRects to avoid excessive allocations
        do {
            NSMutableArray<NSValue *> *t = currentRects;
            currentRects = nextRects;
            nextRects = t;
            [nextRects removeAllObjects];
        } while(NO);
        
        if (currentRects.count == 0) {
            self.clippedRect = CGRectZero;
            return NO;
        }
    }
    
    BOOL first = YES;
    CGRect result = CGRectZero;
    for(NSValue *nextFragment in currentRects) {
        if (first) {
            first = NO;
            result = nextFragment.CGRectValue;
        } else {
            result = CGRectUnion(result, nextFragment.CGRectValue);
        }
    }
    
    if (CGRectEqualToRect(oldRect, result)) {
        return YES;
    }
    
    self.clippedRect = result;
    
    NSUInteger removedCount = 0;
    NSUInteger const fullCount = self.obstructions.count;
    for(NSUInteger i = 0; i < fullCount; i++) {
        NSValue *nextObstruction = self.obstructions[i];
        CGRect const testRect = nextObstruction.CGRectValue;
        if (CGRectIntersectsRect(testRect, result)) {
            if (!CGRectContainsRect(result, testRect)) {
                [self.obstructions replaceObjectAtIndex:(i - removedCount) withObject:@(CGRectIntersection(result, testRect))];
            } else if (removedCount) {
                [self.obstructions replaceObjectAtIndex:(i - removedCount) withObject:nextObstruction];
            };
        } else {
            removedCount++;
        }
    }
    if (removedCount) {
        [self.obstructions removeObjectsInRange:NSMakeRange(fullCount - removedCount, removedCount)];
    }
    
    return YES;
}

- (void)removeRect:(CGRect)rect from:(NSArray<NSValue *> *)srcArray into:(NSMutableArray<NSValue *> *)dstArray startingWith:(NSUInteger)firstIndex {
    for(NSUInteger i = firstIndex, n = srcArray.count; i < n; i++) {
        [self fragmentize:srcArray[i] aroundRect:rect into:dstArray];
    }
}

- (void)testForObstructing:(UIView *)view {
    CGRect testRect = [self.testedView convertRect:view.bounds fromView:view];
    CGRect obstruction = CGRectIntersection(self.clippedRect, testRect);
    if (!CGRectIsEmpty(obstruction)) {
        [self.obstructions addObject:@(obstruction)];
    }
}

- (NSArray<NSValue *> *)buildObstructionRects {
    if (self.obstructions.count == 0) {
        return nil;
    }
    
    NSMutableArray<NSValue *> *currentObstructions = [self.obstructions mutableCopy];
    NSMutableArray<NSValue *> *remainingObstructions = [[NSMutableArray alloc] init];
    NSMutableArray<NSValue *> * const pickedObstructions = [[NSMutableArray alloc] init];
    
    NSComparator areaComparator = ^NSComparisonResult(NSValue *rect1, NSValue *rect2) {
        CGSize const size1 = rect1.CGRectValue.size;
        float const area1 = size1.width * size1.height;
        CGSize const size2 = rect2.CGRectValue.size;
        float const area2 = size2.width * size2.height;
        NSComparisonResult result = (area1 < area2) ? NSOrderedAscending : ((area1 > area2) ? NSOrderedDescending : NSOrderedSame);
        return -result; // invert order -- sort from largest rect to smallest
    };
    
    while(currentObstructions.count > 0) {
        // pick largest obstruction
        [currentObstructions sortUsingComparator:areaComparator];
        NSValue * const nextPicked = [currentObstructions firstObject];
        [pickedObstructions addObject:nextPicked];
        
        // copy others to remaining, after cutting out the picked area
        [self removeRect:nextPicked.CGRectValue from:currentObstructions into:remainingObstructions startingWith:1];
        
        // swap currentObstructions and remainingObstructions to avoid excessive allocations
        do {
            NSMutableArray<NSValue *> *t = currentObstructions;
            currentObstructions = remainingObstructions;
            remainingObstructions = t;
            [remainingObstructions removeAllObjects];
        } while(NO);
    }
    
    return pickedObstructions.count > 0 ? pickedObstructions : nil;
}

- (void)fragmentize:(NSValue *)value aroundRect:(CGRect)rect into:(NSMutableArray<NSValue *> *)array {
    CGRect const valRect = value.CGRectValue;
    if (!CGRectIntersectsRect(valRect, rect)) {
        [array addObject:value];
        return;
    }
    if (CGRectContainsRect(rect, valRect)) {
        return;
    }
    CGRect const trimmedRect = CGRectIntersection(rect, valRect);
    CGRect subRects[] = {
        // left
        CGRectMake(CGRectGetMinX(valRect),
                   CGRectGetMinY(valRect),
                   CGRectGetMinX(trimmedRect) - CGRectGetMinX(valRect),
                   CGRectGetHeight(valRect)),
        
        // mid/top
        CGRectMake(CGRectGetMinX(trimmedRect),
                   CGRectGetMinY(valRect),
                   CGRectGetWidth(trimmedRect),
                   CGRectGetMinY(trimmedRect) - CGRectGetMinY(valRect)),
        
        // mid/bottom
        CGRectMake(CGRectGetMinX(trimmedRect),
                   CGRectGetMaxY(trimmedRect),
                   CGRectGetWidth(trimmedRect),
                   CGRectGetMaxY(valRect) - CGRectGetMaxY(trimmedRect)),
        
        // right
        CGRectMake(CGRectGetMaxX(trimmedRect),
                   CGRectGetMinY(valRect),
                   CGRectGetMaxX(valRect) - CGRectGetMaxX(trimmedRect),
                   CGRectGetHeight(valRect)),
    };
    for(int i = 0; i < 4; i++) {
        if (!CGRectIsEmpty(subRects[i])) {
            [array addObject:@(subRects[i])];
        }
    }
}

@end
