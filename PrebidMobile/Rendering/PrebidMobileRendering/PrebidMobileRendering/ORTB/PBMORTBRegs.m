//
//  PBMORTBRegs.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBRegs.h"
#import "PBMORTBAbstract+Protected.h"

@interface PBMORTBRegs ()
    @property (nonatomic, copy) NSNumber *_coppa;
@end


@implementation PBMORTBRegs

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _ext = [PBMMutableJsonDictionary new];

    return self;
}

- (NSNumber *)coppa {
    return self._coppa;
}

- (void)setCoppa:(NSNumber *)newValue {
    
    if (newValue) {
        if ([newValue isEqualToNumber:@(1)] || [newValue isEqualToNumber:@(0)]) {
            self._coppa = newValue;
            return;
        }
    }
    
    self._coppa = nil;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"coppa"] = self._coppa;
    
    ret[@"ext"] = [self.ext nullIfEmpty];

    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    __coppa = jsonDictionary[@"coppa"];
    
    return self;
}

@end
