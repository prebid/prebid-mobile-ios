//
//  NSMutableDictionary+OxmExtensions.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "NSMutableDictionary+PBMExtensions.h"

static inline BOOL isEmptyVal(id testVal) {
    return !testVal || [testVal isKindOfClass:[NSNull class]];
}

@implementation NSMutableDictionary (Clear)

- (void)pbmRemoveEmptyVals {
    NSArray* keys = self.allKeys;
    for (id key in keys) {
        if (isEmptyVal(self[key])) {
            [self removeObjectForKey:key];
        }
    }
}

- (nonnull NSMutableDictionary *)pbmCopyWithoutEmptyVals {
    
    NSMutableDictionary * const ret = [NSMutableDictionary new];
    
    NSArray * const keys = self.allKeys;
    for (id key in keys) {
        
        const id value = self[key];
        
        if (isEmptyVal(value)) {
            continue;
        }
        
        ret[key] = value;
    }

    return ret;
}

@end
