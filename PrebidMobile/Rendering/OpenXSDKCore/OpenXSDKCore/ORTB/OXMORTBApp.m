//
//  OXMORTBApp.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBApp.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXMORTBPublisher.h"
#import "OXMORTBAppExtPrebid.h"

@implementation OXMORTBApp

- (nonnull instancetype )init {
    if (!(self = [super init])) {
        return nil;
    }
    _cat = @[];
    _sectioncat = @[];
    _pagecat = @[];
    _publisher = [[OXMORTBPublisher alloc] init];
    _extPrebid = [[OXMORTBAppExtPrebid alloc] init];
    
    return self;
}

- (void)setCat:(NSArray<NSString *> *)cat {
    _cat = cat ? [NSArray arrayWithArray:cat] : @[];
}

- (void)setSectioncat:(NSArray<NSString *> *)sectioncat {
    _sectioncat = sectioncat ? [NSArray arrayWithArray:sectioncat] : @[];
}

- (void)setPagecat:(NSArray<NSString *> *)pagecat {
    _pagecat = pagecat ? [NSArray arrayWithArray:pagecat] : @[];
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"id"] = self.id;
    ret[@"name"] = self.name;
    ret[@"bundle"] = self.bundle;
    ret[@"domain"] = self.domain;
    ret[@"storeurl"] = self.storeurl;
    ret[@"ver"] = self.ver;
    ret[@"privacypolicy"] = self.privacypolicy;
    ret[@"paid"] = self.paid;
    ret[@"keywords"] = self.keywords;
    ret[@"publisher"] = [[self.publisher toJsonDictionary] nullIfEmpty];
    
    OXMJsonDictionary * const extPrebidDic = [self.extPrebid toJsonDictionary];
    if (extPrebidDic.count) {
        ret[@"ext"] = @{@"prebid": extPrebidDic};
    }
    
    [ret oxmRemoveEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _id = jsonDictionary[@"id"];
    _name = jsonDictionary[@"name"];
    _bundle = jsonDictionary[@"bundle"];
    _domain = jsonDictionary[@"domain"];
    _storeurl = jsonDictionary[@"storeurl"];
    _cat = jsonDictionary[@"cat"];
    _sectioncat = jsonDictionary[@"sectioncat"];
    _pagecat = jsonDictionary[@"pagecat"];
    _ver = jsonDictionary[@"ver"] ;
    _privacypolicy = jsonDictionary[@"privacypolicy"];
    _paid = jsonDictionary[@"paid"];
    _publisher = [[OXMORTBPublisher alloc] initWithJsonDictionary:jsonDictionary[@"publisher"]];
    _keywords = jsonDictionary[@"keywords"];
    _extPrebid = [[OXMORTBAppExtPrebid alloc] initWithJsonDictionary:jsonDictionary[@"ext"][@"prebid"]];
    
    return self;
}

@end
