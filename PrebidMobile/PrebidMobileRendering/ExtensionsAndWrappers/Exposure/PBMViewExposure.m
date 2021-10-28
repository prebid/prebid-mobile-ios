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

#import "PBMViewExposure.h"
#import <UIKit/UIKit.h>

@implementation PBMViewExposure

@synthesize exposureFactor = _exposureFactor;
@synthesize visibleRectangle = _visibleRectangle;
@synthesize occlusionRectangles = _occlusionRectangles;

- (instancetype)initWithExposureFactor:(float)exposureFactor
                      visibleRectangle:(CGRect)visibleRectangle
                   occlusionRectangles:(NSArray<NSValue *> *)occlusionRectangles
{
    if (!(self = [super init])) {
        return nil;
    }
    _exposureFactor = exposureFactor;
    _visibleRectangle = visibleRectangle;
    _occlusionRectangles = occlusionRectangles;
    return self;
}

+ (instancetype)zeroExposure {
    static dispatch_once_t onceToken;
    static PBMViewExposure *zeroViewExposure;
    dispatch_once(&onceToken, ^{
        zeroViewExposure = [[PBMViewExposure alloc] initWithExposureFactor:0 visibleRectangle:CGRectZero occlusionRectangles:nil];
    });
    return zeroViewExposure;
}

- (float)exposedPercentage {
    return self.exposureFactor * 100.0f;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    PBMViewExposure *other = object;
    return ((self == other)
            || (self.exposureFactor == other.exposureFactor
                && CGRectEqualToRect(self.visibleRectangle, other.visibleRectangle)
                && (self.occlusionRectangles == other.occlusionRectangles || [self.occlusionRectangles isEqual:other.occlusionRectangles])
                )
            );
}

- (NSUInteger)hash {
    NSUInteger hashValue = 0;
    hashValue ^= @(self.exposureFactor).hash;
    hashValue ^= @(self.visibleRectangle).hash;
    hashValue ^= self.occlusionRectangles.hash;
    return hashValue;
}

- (NSString *)description {
    return [self serializeWithNulls:NO escapeQuotes:NO usePercentages:NO floatAppender:^(NSMutableString *s, float f) {
        [s appendFormat:@"%5.3f", f];
    }];
}

- (NSString *)serializeWithFormatter:(NSNumberFormatter *)numberFormatter {
    return [self serializeWithNulls:YES escapeQuotes:YES usePercentages:YES floatAppender:^(NSMutableString *s, float f) {
        [s appendString:[numberFormatter stringFromNumber:@(f)]];
    }];
}

- (NSString *)serializeWithNulls:(BOOL)includeNulls escapeQuotes:(BOOL)escapeQuotes usePercentages:(BOOL)usePercentages floatAppender:(void (^_Nonnull)(NSMutableString *, float))floatAppender {
    NSMutableString *desc = [[NSMutableString alloc] init];
    void (^addQuote)(void) = ^{ [desc appendString:(escapeQuotes ? @"\\\"" : @"\"")]; };
    
    [desc appendString:@"{"];
    addQuote();
    [desc appendString:usePercentages ? @"exposedPercentage" : @"exposureFactor"];
    addQuote();
    [desc appendString:@": "];
    floatAppender(desc, self.exposedPercentage);
    
    [desc appendString:@", "];
    addQuote();
    [desc appendString:@"visibleRectangle"];
    addQuote();
    [desc appendString:@": "];
    [self appendRect:self.visibleRectangle toString:desc addQuoteBlock:addQuote floatAppender:floatAppender];
    
    if (includeNulls || self.occlusionRectangles != nil) {
        [desc appendString:@", "];
        addQuote();
        [desc appendString:@"occlusionRectangles"];
        addQuote();
        [desc appendString:@": "];
        if (self.occlusionRectangles != nil) {
            [desc appendString:@"["];
            BOOL first = YES;
            for(NSValue *nextRectVal in self.occlusionRectangles) {
                if (first) {
                    first = NO;
                } else {
                    [desc appendString:@", "];
                }
                [self appendRect:nextRectVal.CGRectValue toString:desc addQuoteBlock:addQuote floatAppender:floatAppender];
            }
            [desc appendString:@"]"];
        } else {
            [desc appendString:@"null"];
        }
    }
    
    [desc appendString:@"}"];
    
    return desc;
}

- (void)appendRect:(CGRect)rect toString:(NSMutableString *)string addQuoteBlock:(void (^_Nonnull)(void))addQuote floatAppender:(void (^_Nonnull)(NSMutableString *, float))floatAppender {
    [string appendString:@"{"];
    addQuote();
    [string appendString:@"x"];
    addQuote();
    [string appendString:@": "];
    floatAppender(string, rect.origin.x);
    [string appendString:@", "];
    addQuote();
    [string appendString:@"y"];
    addQuote();
    [string appendString:@": "];
    floatAppender(string, rect.origin.y);
    [string appendString:@", "];
    addQuote();
    [string appendString:@"width"];
    addQuote();
    [string appendString:@": "];
    floatAppender(string, rect.size.width);
    [string appendString:@", "];
    addQuote();
    [string appendString:@"height"];
    addQuote();
    [string appendString:@": "];
    floatAppender(string, rect.size.height);
    [string appendString:@"}"];
}

@end
