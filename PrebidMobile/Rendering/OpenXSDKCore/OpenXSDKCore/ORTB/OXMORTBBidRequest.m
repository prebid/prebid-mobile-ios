//
//  OXMORTBBidRequest.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMORTBBidRequest.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXMORTBApp.h"
#import "OXMORTBBidRequestExtPrebid.h"
#import "OXMORTBDevice.h"
#import "OXMORTBImp.h"
#import "OXMORTBRegs.h"
#import "OXMORTBSource.h"
#import "OXMORTBUser.h"

@implementation OXMORTBBidRequest

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    //_requestID = nil;
    _imp = @[[OXMORTBImp new]];
    _app = [OXMORTBApp new];
    _device = [OXMORTBDevice new];
    _user = [OXMORTBUser new];
    _regs = [OXMORTBRegs new];
    _source = [OXMORTBSource new];
    _extPrebid = [OXMORTBBidRequestExtPrebid new];
    
    return self;
}
- (void)setImp:(NSArray<OXMORTBImp *> *)imp {
    _imp = imp ? [NSArray arrayWithArray:imp] : @[];
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    NSMutableArray<OXMJsonDictionary *> *impressions = [NSMutableArray<OXMJsonDictionary *> new];
    for (OXMORTBImp *imp in self.imp) {
        [impressions addObject:[imp toJsonDictionary]];
    }
    
    ret[@"id"] = self.requestID;
    ret[@"imp"] = impressions;
    
    ret[@"app"] = [self.app toJsonDictionary];
    ret[@"device"] = [self.device toJsonDictionary];
    ret[@"user"] = [self.user toJsonDictionary];
    ret[@"test"] = self.test;
    ret[@"tmax"] = self.tmax;
    ret[@"regs"] = [[self.regs toJsonDictionary] nullIfEmpty];
    ret[@"source"] = [[self.source toJsonDictionary] nullIfEmpty];
    
    OXMMutableJsonDictionary * const ext = [OXMMutableJsonDictionary new];
    ext[@"prebid"] = [[self.extPrebid toJsonDictionary] nullIfEmpty];
    ret[@"ext"] = [[ext oxmCopyWithoutEmptyVals] nullIfEmpty];
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _requestID = jsonDictionary[@"id"];
    
    NSMutableArray<OXMORTBImp *> *impressions = [NSMutableArray<OXMORTBImp *> new];
    NSMutableArray<OXMJsonDictionary *> *impressionsData = jsonDictionary[@"imp"];
    for (OXMJsonDictionary *impressionData in impressionsData) {
        if (impressionData && [impressionData isKindOfClass:[NSDictionary class]])
            [impressions addObject:[[OXMORTBImp alloc] initWithJsonDictionary:impressionData]];
    }
    
    _imp = impressions;
    
    _app = [[OXMORTBApp alloc] initWithJsonDictionary:jsonDictionary[@"app"]];
    _device = [[OXMORTBDevice alloc] initWithJsonDictionary:jsonDictionary[@"device"]];
    _user = [[OXMORTBUser alloc] initWithJsonDictionary:jsonDictionary[@"user"]];
    _test = jsonDictionary[@"test"];
    _tmax = jsonDictionary[@"tmax"];
    _regs = [[OXMORTBRegs alloc] initWithJsonDictionary:jsonDictionary[@"regs"]];
    _source = [[OXMORTBSource alloc] initWithJsonDictionary:jsonDictionary[@"source"]];
    
    _extPrebid = [[OXMORTBBidRequestExtPrebid alloc] initWithJsonDictionary:jsonDictionary[@"ext"][@"prebid"] ?: @{}];
    
    return self;
}

@end
