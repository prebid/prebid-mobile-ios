/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMORTBImp.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBBanner.h"
#import "PBMORTBImpExtPrebid.h"
#import "PBMORTBImpExtSkadn.h"
#import "PBMORTBNative.h"
#import "PBMORTBPmp.h"
#import "PBMORTBVideo.h"

@implementation PBMORTBImp

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    //_impID = nil;
    _pmp = [PBMORTBPmp new];
    _instl = @0;
    _clickbrowser = @0;
    _secure = @0;
    _extPrebid = [[PBMORTBImpExtPrebid alloc] init];
    _extSkadn = [PBMORTBImpExtSkadn new];
    _extData = [NSMutableDictionary<NSString *, id> new];
    
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"id"] = self.impID;
    ret[@"banner"] = [[self.banner toJsonDictionary] nullIfEmpty];
    ret[@"video"] = [[self.video toJsonDictionary] nullIfEmpty];
    ret[@"native"] = [[self.native toJsonDictionary] nullIfEmpty];
    ret[@"pmp"] = [[self.pmp toJsonDictionary] nullIfEmpty];
    ret[@"displaymanager"] = self.displaymanager;
    ret[@"displaymanagerver"] = self.displaymanagerver;
    ret[@"instl"] = self.instl;
    ret[@"tagid"] = self.tagid;
    ret[@"clickbrowser"] = self.clickbrowser;
    ret[@"secure"] = self.secure;
    
    ret[@"ext"] = [[self extDictionary] nullIfEmpty];
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _impID = jsonDictionary[@"id"];
    
    id bannerData = jsonDictionary[@"banner"];
    if (bannerData && [bannerData isKindOfClass:[NSDictionary class]]) {
        self.banner = [[PBMORTBBanner alloc] initWithJsonDictionary:bannerData];
    }
    
    id videoData = jsonDictionary[@"video"];
    if (videoData && [videoData isKindOfClass:[NSDictionary class]]) {
        self.video = [[PBMORTBVideo alloc] initWithJsonDictionary:videoData];
    }
    id nativeData = jsonDictionary[@"native"];
    if (nativeData && [nativeData isKindOfClass:[NSDictionary class]]) {
        self.native = [[PBMORTBNative alloc] initWithJsonDictionary:nativeData];
    }
    
    _pmp = [[PBMORTBPmp alloc] initWithJsonDictionary:jsonDictionary[@"pmp"]];
    
    _displaymanager = jsonDictionary[@"displaymanager"];
    _displaymanagerver = jsonDictionary[@"displaymanagerver"];
    _instl = jsonDictionary[@"instl"];
    _tagid = jsonDictionary[@"tagid"];
    _clickbrowser = jsonDictionary[@"clickbrowser"];
    _secure = jsonDictionary[@"secure"];
    
    _extPrebid = [[PBMORTBImpExtPrebid alloc] initWithJsonDictionary:jsonDictionary[@"ext"][@"prebid"]];
    _extSkadn = [[PBMORTBImpExtSkadn alloc] initWithJsonDictionary:jsonDictionary[@"ext"][@"skadn"]];
    
    _extData = jsonDictionary[@"ext"][@"data"];
    _extKeywords = jsonDictionary[@"ext"][@"keywords"];
    _extGPID = jsonDictionary[@"ext"][@"gpid"];
    //take all key values stored in ext because they will be filtered before sending
    _extOrtbObject = jsonDictionary[@"ext"];
    
    return self;
}

- (nonnull PBMJsonDictionary *)extDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
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
    
    if (self.extData && self.extData.count > 0) {
        ret[@"data"] = self.extData;
    }
    
    if (self.extKeywords && self.extKeywords.length > 0) {
        ret[@"keywords"] = self.extKeywords;
    }
    
    if (self.extGPID) {
        ret[@"gpid"] = self.extGPID;
    }
    
    //loop through extra fields and add arbitrary ones but don't override the previously provided ones
    //leave this loop at the end (or beginning) of this method so we don't duplicate fields and override provided ones
    for (id key in self.extOrtbObject)
        if ([ret objectForKey:key] == nil)
            [ret setObject:[self.extOrtbObject objectForKey:key] forKey: key];
            
    return [ret pbmCopyWithoutEmptyVals];
}

@end
