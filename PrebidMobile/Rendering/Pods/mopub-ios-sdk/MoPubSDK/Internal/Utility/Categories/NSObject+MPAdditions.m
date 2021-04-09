//
//  NSObject+MPAdditions.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "NSObject+MPAdditions.h"

@implementation NSObject (MPAdditions)

- (NSString *)className {
    return NSStringFromClass(self.class);
}

@end
