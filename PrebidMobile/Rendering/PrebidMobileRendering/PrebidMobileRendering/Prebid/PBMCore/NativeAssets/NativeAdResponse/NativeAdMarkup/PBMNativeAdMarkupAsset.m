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

#import "PBMNativeAdMarkupAsset.h"

#import "PBMLog.h"
#import "PBMConstants.h"

@implementation PBMNativeAdMarkupAsset

- (instancetype)initWithData:(PBMNativeAdMarkupData *)data {
    if (!(self = [super init])) {
        return nil;
    }
    _data = data;
    return self;
}

- (instancetype)initWithImage:(PBMNativeAdMarkupImage *)image {
    if (!(self = [super init])) {
        return nil;
    }
    _img = image;
    return self;
}

- (instancetype)initWithTitle:(PBMNativeAdMarkupTitle *)title {
    if (!(self = [super init])) {
        return nil;
    }
    _title = title;
    return self;
}

- (instancetype)initWithVideo:(PBMNativeAdMarkupVideo *)video {
    if (!(self = [super init])) {
        return nil;
    }
    _video = video;
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _assetID = jsonDictionary[@"id"];
    _required = jsonDictionary[@"required"];
    _ext = jsonDictionary[@"ext"];
    
    PBMJsonDictionary * const dataJson = jsonDictionary[@"data"];
    if (dataJson) {
        // TODO: Handle (optional) data parsing error?
        _data = [[PBMNativeAdMarkupData alloc] initWithJsonDictionary:dataJson error:nil];
    }
    
    PBMJsonDictionary * const imageJson = jsonDictionary[@"img"];
    if (imageJson) {
        // TODO: Handle (optional) image parsing error?
        _img = [[PBMNativeAdMarkupImage alloc] initWithJsonDictionary:imageJson error:nil];
    }
    
    PBMJsonDictionary * const titleJson = jsonDictionary[@"title"];
    if (titleJson) {
        // TODO: Handle (optional) title parsing error?
        _title = [[PBMNativeAdMarkupTitle alloc] initWithJsonDictionary:titleJson error:nil];
    }
    
    PBMJsonDictionary * const videoJson = jsonDictionary[@"video"];
    if (videoJson) {
        // TODO: Handle (optional) video parsing error?
        _video = [[PBMNativeAdMarkupVideo alloc] initWithJsonDictionary:videoJson error:nil];
    }
    
    if (!(_data || _img || _title || _video)) {
        PBMLogWarn(@"'data', 'img', 'title' or 'video' must be present in JSON for nativeAsset, but all 4 are absent");
    }
    
    PBMJsonDictionary * const linkJson = jsonDictionary[@"link"];
    if (linkJson) {
        // TODO: Handle (optional) link parsing error?
        _link = [[PBMNativeAdMarkupLink alloc] initWithJsonDictionary:linkJson error:nil];
    }
    
    if (error) {
        *error = nil;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    PBMNativeAdMarkupAsset *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(PBMNativeAdMarkupAsset *src) { return src.assetID; })
                && objComparator(^(PBMNativeAdMarkupAsset *src) { return src.required; })
                && objComparator(^(PBMNativeAdMarkupAsset *src) { return src.title; })
                && objComparator(^(PBMNativeAdMarkupAsset *src) { return src.img; })
                && objComparator(^(PBMNativeAdMarkupAsset *src) { return src.video; })
                && objComparator(^(PBMNativeAdMarkupAsset *src) { return src.data; })
                && objComparator(^(PBMNativeAdMarkupAsset *src) { return src.link; })
                && objComparator(^(PBMNativeAdMarkupAsset *src) { return src.ext; })
                )
            );
}

@end
