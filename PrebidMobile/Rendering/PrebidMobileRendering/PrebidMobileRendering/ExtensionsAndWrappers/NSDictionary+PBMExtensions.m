//
//  NSDictionary+OxmExtensions.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "NSDictionary+PBMExtensions.h"

@implementation NSDictionary (PBMExtensions)

- (nonnull id)nullIfEmpty {
    return (self.count > 0) ? self : [NSNull null];
}

@end
