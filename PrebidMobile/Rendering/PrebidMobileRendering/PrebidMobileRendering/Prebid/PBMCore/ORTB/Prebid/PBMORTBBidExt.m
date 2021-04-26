//
//  PBMORTBBidExt.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBidExt.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBBidExtPrebid.h"
#import "PBMORTBBidExtSkadn.h"

@implementation PBMORTBBidExt

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    
    _bidder = jsonDictionary[@"bidder"];
    
    PBMJsonDictionary * const prebidDic = jsonDictionary[@"prebid"];
    if (prebidDic) {
        _prebid = [[PBMORTBBidExtPrebid alloc] initWithJsonDictionary:prebidDic];
    }
    
    PBMJsonDictionary * const skadnDict = jsonDictionary[@"skadn"];
    if (skadnDict) {
        _skadn = [[PBMORTBBidExtSkadn alloc] initWithJsonDictionary:skadnDict];
    }
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"bidder"] = self.bidder;
    ret[@"prebid"] = [self.prebid toJsonDictionary];
    ret[@"skadn"] = [self.skadn toJsonDictionary];
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
