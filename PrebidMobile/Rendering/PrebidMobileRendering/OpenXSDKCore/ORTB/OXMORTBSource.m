//
//  OXMORTBSource.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBSource.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXMORTBSourceExtOMID.h"

@implementation OXMORTBSource

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _extOMID = [[OXMORTBSourceExtOMID alloc] init];
    return self;
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    ret[@"fd"] = self.fd;
    ret[@"tid"] = self.tid;
    ret[@"pchain"] = self.pchain;
    
    OXMJsonDictionary * const extOmidDic = [self.extOMID toJsonDictionary];
    if (extOmidDic.count) {
        ret[@"ext"] = extOmidDic;
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _fd = jsonDictionary[@"fd"];
    _tid = jsonDictionary[@"tid"];
    _pchain = jsonDictionary[@"pchain"];
    
    _extOMID = [[OXMORTBSourceExtOMID alloc] initWithJsonDictionary:jsonDictionary[@"ext"]];
    
    return self;
}

@end
