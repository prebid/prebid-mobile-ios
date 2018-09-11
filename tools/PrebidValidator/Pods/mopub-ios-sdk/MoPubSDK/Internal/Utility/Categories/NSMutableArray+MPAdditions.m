//
//  NSMutableArray+MPAdditions.m
//  MoPubSampleApp
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "NSMutableArray+MPAdditions.h"

@implementation NSMutableArray (MPAdditions)

- (id)removeFirst {
    if (self.count == 0) {
        return nil;
    }
    id firstObject = self.firstObject;
    [self removeObjectAtIndex:0];
    return firstObject;
}

@end
