//
//  OXMORTBImp.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBImp.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXMORTBBanner.h"
#import "OXMORTBImpExtPrebid.h"
#import "OXMORTBImpExtSkadn.h"
#import "OXMORTBNative.h"
#import "OXMORTBPmp.h"
#import "OXMORTBVideo.h"

@implementation OXMORTBImp

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    //_impID = nil;
    _pmp = [OXMORTBPmp new];
    _displaymanager = @"openx";
    _instl = @0;
    _clickbrowser = @0;
    _secure = @0;
    _extPrebid = [[OXMORTBImpExtPrebid alloc] init];
    _extSkadn = [OXMORTBImpExtSkadn new];
    
    return self;
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"id"] = self.impID;
    ret[@"banner"] = [self.banner toJsonDictionary];
    ret[@"video"] = [self.video toJsonDictionary];
    ret[@"native"] = [self.native toJsonDictionary];
    ret[@"pmp"] = [[self.pmp toJsonDictionary] nullIfEmpty];
    ret[@"displaymanager"] = self.displaymanager;
    ret[@"displaymanagerver"] = self.displaymanagerver;
    ret[@"instl"] = self.instl;
    ret[@"tagid"] = self.tagid;
    ret[@"clickbrowser"] = self.clickbrowser;
    ret[@"secure"] = self.secure;
    
    ret[@"ext"] = [self extDictionary];
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _impID = jsonDictionary[@"id"];
    
    id bannerData = jsonDictionary[@"banner"];
    if (bannerData && [bannerData isKindOfClass:[NSDictionary class]]) {
        self.banner = [[OXMORTBBanner alloc] initWithJsonDictionary:bannerData];
    }
    
    id videoData = jsonDictionary[@"video"];
    if (videoData && [videoData isKindOfClass:[NSDictionary class]]) {
        self.video = [[OXMORTBVideo alloc] initWithJsonDictionary:videoData];
    }
    id nativeData = jsonDictionary[@"native"];
    if (nativeData && [nativeData isKindOfClass:[NSDictionary class]]) {
        self.native = [[OXMORTBNative alloc] initWithJsonDictionary:nativeData];
    }
    
    _pmp = [[OXMORTBPmp alloc] initWithJsonDictionary:jsonDictionary[@"pmp"]];
    
    _displaymanager = jsonDictionary[@"displaymanager"];
    _displaymanagerver = jsonDictionary[@"displaymanagerver"];
    _instl = jsonDictionary[@"instl"];
    _tagid = jsonDictionary[@"tagid"];
    _clickbrowser = jsonDictionary[@"clickbrowser"];
    _secure = jsonDictionary[@"secure"];
    
    _extPrebid = [[OXMORTBImpExtPrebid alloc] initWithJsonDictionary:jsonDictionary[@"ext"][@"prebid"]];
    _extSkadn = [[OXMORTBImpExtSkadn alloc] initWithJsonDictionary:jsonDictionary[@"ext"][@"skadn"]];
    
    _extContextData = jsonDictionary[@"ext"][@"context"][@"data"];
    
    return self;
}

- (nonnull OXMJsonDictionary *)extDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    // FIXME: (PB-X) Check the necessity of branching the logic with server devs
    id extPrebidObj = [[self.extPrebid toJsonDictionary] nullIfEmpty];
    if (extPrebidObj != [NSNull null]) {
        ret[@"prebid"] = extPrebidObj;
    } else {
        ret[@"dlp"] = @(1);
    }
    
    id extSkadnObj = [[self.extSkadn toJsonDictionary] nullIfEmpty];
    if (extSkadnObj != [NSNull null]) {
        ret[@"skadn"] = extSkadnObj;
    }
    
    if (self.extContextData) {
        ret[@"context"] = @{
            @"data": self.extContextData,
        };
    }
    
    return [ret oxmCopyWithoutEmptyVals];
}

@end
