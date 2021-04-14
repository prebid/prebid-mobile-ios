//
//  NSNumber+OXAORTBNative.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "NSNumber+OXAORTBNative.h"

@implementation NSNumber (OXAORTBNative)

- (NSNumber *)integerNumber {
    if (!strcmp(self.objCType, @encode(NSInteger))) {
        return self;
    } else {
        return @(self.integerValue);
    }
}

@end
