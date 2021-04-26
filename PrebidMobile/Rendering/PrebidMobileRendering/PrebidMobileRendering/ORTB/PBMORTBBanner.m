//
//  PBMORTBBanner.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBanner.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBFormat.h"

@implementation PBMORTBBanner

- (nonnull instancetype)init {
    if(!(self = [super init])) {
        return nil;
    }
    _api = @[];
    _format = @[];
    return self;
}

- (void)setFormat:(NSArray<PBMORTBFormat *> *)format {
    _format = format ? [NSArray arrayWithArray:format] : @[];
}

- (void)setApi:(NSArray<NSNumber *> *)api {
    _api = api ? [NSArray arrayWithArray:api] : @[];
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"pos"] = self.pos;
    ret[@"api"] = self.api;
    if (self.format.count > 0) {
        NSMutableArray<PBMJsonDictionary *> * const formatsArr = [[NSMutableArray alloc] initWithCapacity:self.format.count];
        for(PBMORTBFormat *nextFormat in self.format) {
            [formatsArr addObject:[nextFormat toJsonDictionary]];
        }
        ret[@"format"] = formatsArr;
    }
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if(!(self = [super init])) {
        return nil;
    }
    _pos = jsonDictionary[@"pos"];
    _api = jsonDictionary[@"api"];
    
    NSArray<PBMJsonDictionary *> * const formatsArr = jsonDictionary[@"format"];
    if (formatsArr) {
        NSMutableArray<PBMORTBFormat *> * const newFormat = [[NSMutableArray alloc] initWithCapacity:formatsArr.count];
        for(PBMJsonDictionary *nextFormatDic in jsonDictionary[@"format"]) {
            [newFormat addObject:[[PBMORTBFormat alloc] initWithJsonDictionary:nextFormatDic]];
        }
        _format = newFormat;
    } else {
        _format = @[];
    }
    
    return self;
}

@end
