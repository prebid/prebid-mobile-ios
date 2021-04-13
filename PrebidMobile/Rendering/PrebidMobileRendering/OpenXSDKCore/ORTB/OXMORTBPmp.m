//
//  OXMORTBPmp.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBPmp.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXMORTBDeal.h"

@implementation OXMORTBPmp

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _deals = @[];
    
    return self;
}

- (void)setDeals:(NSArray<OXMORTBDeal *> *)deals {
    _deals = deals ? [NSArray arrayWithArray:deals] : @[];
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"private_auction"] = self.private_auction;
    
    NSMutableArray<OXMJsonDictionary *> *deals = [NSMutableArray<OXMJsonDictionary *> new];
    for (OXMORTBDeal *deal in self.deals) {
        [deals addObject:[deal toJsonDictionary]];
    }
    if (deals.count > 0) {
        ret[@"deals"] = deals;
    }
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _private_auction = jsonDictionary[@"private_auction"];
    
    NSMutableArray<OXMORTBDeal *> *deals = [NSMutableArray<OXMORTBDeal *> new];

    NSArray *dealsData = jsonDictionary[@"deals"];
    for (OXMJsonDictionary *dealData in dealsData) {
        if (dealData && [dealData isKindOfClass:[NSDictionary class]]) {
            [deals addObject:[[OXMORTBDeal alloc] initWithJsonDictionary:dealData]];
        }
    }
    
    _deals = deals;
    
    return self;
}

@end
