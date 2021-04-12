//
//  OXAORTBBidExt.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAORTBBidExt.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXAORTBBidExtPrebid.h"
#import "OXAORTBBidExtSkadn.h"

@implementation OXAORTBBidExt

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    
    _bidder = jsonDictionary[@"bidder"];
    
    OXMJsonDictionary * const prebidDic = jsonDictionary[@"prebid"];
    if (prebidDic) {
        _prebid = [[OXAORTBBidExtPrebid alloc] initWithJsonDictionary:prebidDic];
    }
    
    OXMJsonDictionary * const skadnDict = jsonDictionary[@"skadn"];
    if (skadnDict) {
        _skadn = [[OXAORTBBidExtSkadn alloc] initWithJsonDictionary:skadnDict];
    }
    
    return self;
}

- (OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary * const ret = [[OXMMutableJsonDictionary alloc] init];
    
    ret[@"bidder"] = self.bidder;
    ret[@"prebid"] = [self.prebid toJsonDictionary];
    ret[@"skadn"] = [self.skadn toJsonDictionary];
    
    [ret oxmRemoveEmptyVals];
    
    return ret;
}

@end
