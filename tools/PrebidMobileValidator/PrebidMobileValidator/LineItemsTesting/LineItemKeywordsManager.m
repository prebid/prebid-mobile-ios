//
//  PCKeywordsManager.m
//  PriceCheckTestApp
//
//  Created by Nicole Hedley on 25/08/2016.
//  Copyright © 2016 Nicole Hedley. All rights reserved.
//

#import "LineItemKeywordsManager.h"

NSString *__nonnull const KeywordsManagerPriceKey = @"hb_pb";

CGFloat const KeywordsManagerPriceFiftyCentsRange = 0.50f;

@implementation LineItemKeywordsManager

+ (NSDictionary<NSString *, NSString *> *)keywordsWithBidPrice:(double)bidPrice {
    NSMutableDictionary *keywords = [[NSMutableDictionary alloc] init];
    
    keywords[KeywordsManagerPriceKey] =
    [self formatValue:bidPrice
              toRange:KeywordsManagerPriceFiftyCentsRange];
    
    return (keywords);
}

+ (nonnull NSString *)formatValue:(CGFloat)value toRange:(CGFloat)range {
    NSString *__nonnull formattedValue = [NSString
                                          stringWithFormat:@"%.2f", [self roundValue:value toRange:range]];
    
    return (formattedValue);
}

+ (CGFloat)roundValue:(CGFloat)value toRange:(CGFloat)range {
    CGFloat newValue = value;
    
    if (range != 0)
        newValue = ((int)(value / range)) * range;
    
    return (newValue);
}

+ (NSArray *) reservedKeys {
    static dispatch_once_t reservedKeysToken;
    static NSArray *keys;
    dispatch_once(&reservedKeysToken, ^{
        keys = @[KeywordsManagerPriceKey];
    });
    return keys;
}

@end
