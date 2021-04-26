//
//  NSNumber+PBMORTBNative.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "NSNumber+PBMORTBNative.h"

@implementation NSNumber (PBMORTBNative)

- (NSNumber *)integerNumber {
    if (!strcmp(self.objCType, @encode(NSInteger))) {
        return self;
    } else {
        return @(self.integerValue);
    }
}

@end
