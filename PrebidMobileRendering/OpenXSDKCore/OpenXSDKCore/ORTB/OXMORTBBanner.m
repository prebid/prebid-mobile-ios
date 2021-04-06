//
//  OXMORTBBanner.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBBanner.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXMORTBFormat.h"

@implementation OXMORTBBanner

- (nonnull instancetype)init {
    if(!(self = [super init])) {
        return nil;
    }
    _api = @[];
    _format = @[];
    return self;
}

- (void)setFormat:(NSArray<OXMORTBFormat *> *)format {
    _format = format ? [NSArray arrayWithArray:format] : @[];
}

- (void)setApi:(NSArray<NSNumber *> *)api {
    _api = api ? [NSArray arrayWithArray:api] : @[];
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"pos"] = self.pos;
    ret[@"api"] = self.api;
    if (self.format.count > 0) {
        NSMutableArray<OXMJsonDictionary *> * const formatsArr = [[NSMutableArray alloc] initWithCapacity:self.format.count];
        for(OXMORTBFormat *nextFormat in self.format) {
            [formatsArr addObject:[nextFormat toJsonDictionary]];
        }
        ret[@"format"] = formatsArr;
    }
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if(!(self = [super init])) {
        return nil;
    }
    _pos = jsonDictionary[@"pos"];
    _api = jsonDictionary[@"api"];
    
    NSArray<OXMJsonDictionary *> * const formatsArr = jsonDictionary[@"format"];
    if (formatsArr) {
        NSMutableArray<OXMORTBFormat *> * const newFormat = [[NSMutableArray alloc] initWithCapacity:formatsArr.count];
        for(OXMJsonDictionary *nextFormatDic in jsonDictionary[@"format"]) {
            [newFormat addObject:[[OXMORTBFormat alloc] initWithJsonDictionary:nextFormatDic]];
        }
        _format = newFormat;
    } else {
        _format = @[];
    }
    
    return self;
}

@end
