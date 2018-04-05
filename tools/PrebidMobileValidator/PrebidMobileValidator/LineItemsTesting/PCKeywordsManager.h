//
//  PCKeywordsManager.h
//  PriceCheckTestApp
//
//  Created by Nicole Hedley on 25/08/2016.
//  Copyright © 2016 Nicole Hedley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PCKeywordsManager : NSObject

/**
 * this method provides the list of keywords that pricecheck will pass values by default
 */

+ (nonnull NSArray *)reservedKeys;

/**
 * The bid price is passed in & a dictionary of keys & values from the bid response object is created
 */
+ (nonnull NSDictionary<NSString *, NSString *> *)keywordsWithBidPrice:(double)bidPrice;


@end
