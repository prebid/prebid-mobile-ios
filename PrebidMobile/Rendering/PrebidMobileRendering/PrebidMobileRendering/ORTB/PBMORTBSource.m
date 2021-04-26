//
//  PBMORTBSource.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBSource.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBSourceExtOMID.h"

@implementation PBMORTBSource

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _extOMID = [[PBMORTBSourceExtOMID alloc] init];
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    ret[@"fd"] = self.fd;
    ret[@"tid"] = self.tid;
    ret[@"pchain"] = self.pchain;
    
    PBMJsonDictionary * const extOmidDic = [self.extOMID toJsonDictionary];
    if (extOmidDic.count) {
        ret[@"ext"] = extOmidDic;
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _fd = jsonDictionary[@"fd"];
    _tid = jsonDictionary[@"tid"];
    _pchain = jsonDictionary[@"pchain"];
    
    _extOMID = [[PBMORTBSourceExtOMID alloc] initWithJsonDictionary:jsonDictionary[@"ext"]];
    
    return self;
}

@end
