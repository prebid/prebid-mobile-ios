//
//  OXMORTBRegs.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBRegs.h"
#import "OXMORTBAbstract+Protected.h"

@interface OXMORTBRegs ()
    @property (nonatomic, copy) NSNumber *_coppa;
@end


@implementation OXMORTBRegs

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _ext = [OXMMutableJsonDictionary new];

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

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"coppa"] = self._coppa;
    
    ret[@"ext"] = [self.ext nullIfEmpty];

    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    __coppa = jsonDictionary[@"coppa"];
    
    return self;
}

@end
