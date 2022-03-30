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

#import "PBMORTBBid.h"
#import "PBMORTBAbstractResponse+Protected.h"

@implementation PBMORTBBid

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _bidID = @"";
    _impid = @"";
    _price = @(0.0f);
    return self;
}

- (void)setAdomain:(NSArray<NSString *> *)adomain {
    _adomain = adomain ? [NSArray arrayWithArray:adomain] : nil;
}

- (void)setCat:(NSArray<NSString *> *)cat {
    _cat = cat ? [NSArray arrayWithArray:cat] : nil;
}

- (void)setAttr:(NSArray<NSNumber *> *)attr {
    _attr = attr ? [NSArray arrayWithArray:attr] : nil;
}

- (void)populateJsonDictionary:(PBMMutableJsonDictionary *)jsonDictionary {
    [super populateJsonDictionary:jsonDictionary];
    
    jsonDictionary[@"id"] = self.bidID;
    jsonDictionary[@"impid"] = self.impid;
    jsonDictionary[@"price"] = self.price;
    
    jsonDictionary[@"nurl"] = self.nurl;
    jsonDictionary[@"burl"] = self.burl;
    jsonDictionary[@"lurl"] = self.lurl;
    jsonDictionary[@"adm"] = self.adm;
    jsonDictionary[@"adid"] = self.adid;
    jsonDictionary[@"adomain"] = self.adomain;
    jsonDictionary[@"bundle"] = self.bundle;
    jsonDictionary[@"iurl"] = self.iurl;
    jsonDictionary[@"cid"] = self.cid;
    jsonDictionary[@"crid"] = self.crid;
    jsonDictionary[@"tactic"] = self.tactic;
    jsonDictionary[@"cat"] = self.cat;
    jsonDictionary[@"attr"] = self.attr;
    jsonDictionary[@"api"] = self.api;
    jsonDictionary[@"protocol"] = self.protocol;
    jsonDictionary[@"qagmediarating"] = self.qagmediarating;
    jsonDictionary[@"language"] = self.language;
    jsonDictionary[@"dealid"] = self.dealid;
    jsonDictionary[@"w"] = self.w;
    jsonDictionary[@"h"] = self.h;
    jsonDictionary[@"wratio"] = self.wratio;
    jsonDictionary[@"hratio"] = self.hratio;
    jsonDictionary[@"exp"] = self.exp;
    
    [jsonDictionary pbmRemoveEmptyVals];
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary extParser:(id (^)(PBMJsonDictionary *))extParser {
    if (!(self = [super initWithJsonDictionary:jsonDictionary extParser:extParser])) {
        return nil;
    }
    
    _bidID = jsonDictionary[@"id"];
    _impid = jsonDictionary[@"impid"];
    _price = jsonDictionary[@"price"];
    
    if (!(_bidID && _impid && _price)) {
        return nil;
    }
    
    _nurl = jsonDictionary[@"nurl"];
    _burl = jsonDictionary[@"burl"];
    _lurl = jsonDictionary[@"lurl"];
    _adm = jsonDictionary[@"adm"];
    _adid = jsonDictionary[@"adid"];
    _adomain = jsonDictionary[@"adomain"];
    _bundle = jsonDictionary[@"bundle"];
    _iurl = jsonDictionary[@"iurl"];
    _cid = jsonDictionary[@"cid"];
    _crid = jsonDictionary[@"crid"];
    _tactic = jsonDictionary[@"tactic"];
    _cat = jsonDictionary[@"cat"];
    _attr = jsonDictionary[@"attr"];
    _api = jsonDictionary[@"api"];
    _protocol = jsonDictionary[@"protocol"];
    _qagmediarating = jsonDictionary[@"qagmediarating"];
    _language = jsonDictionary[@"language"];
    _dealid = jsonDictionary[@"dealid"];
    _w = jsonDictionary[@"w"];
    _h = jsonDictionary[@"h"];
    _wratio = jsonDictionary[@"wratio"];
    _hratio = jsonDictionary[@"hratio"];
    _exp = jsonDictionary[@"exp"];
    
    return self;
}

@end
