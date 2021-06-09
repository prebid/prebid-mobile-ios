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

#import "PBMNativeAdMarkup.h"

#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"

#import "PBMLog.h"

@implementation PBMNativeAdMarkup

- (instancetype)initWithLink:(PBMNativeAdMarkupLink *)link {
    if (!(self = [super init])) {
        return nil;
    }
    _link = link;
    return self;
}

- (instancetype)initWithJsonString:(NSString *)jsonString error:(NSError * _Nullable __autoreleasing *)error {
    NSError *localError = nil;
    PBMJsonDictionary * const jsonDic = [PBMFunctions dictionaryFromJSONString:jsonString error:&localError];
    if (!jsonDic) {
        if (error) {
            *error = localError;
        }
        return nil;
    }
    return [self initWithJsonDictionary:jsonDic error:error];
}

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary
                                 error:(NSError * _Nullable __autoreleasing *)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _version = [jsonDictionary[@"ver"] copy];
    
    NSArray<PBMJsonDictionary *> * const rawAssets = jsonDictionary[@"assets"];
    if (rawAssets) {
        NSMutableArray<PBMNativeAdMarkupAsset *> * const assets = [[NSMutableArray alloc] initWithCapacity:rawAssets.count];
        for (PBMJsonDictionary *nextRawAsset in rawAssets) {
            NSError *assetError = nil;
            PBMNativeAdMarkupAsset * const nextAsset = [[PBMNativeAdMarkupAsset alloc]
                                                        initWithJsonDictionary:nextRawAsset error:&assetError];
            // TODO: Handle 'assetError'?
            if (nextAsset) {
                [assets addObject:nextAsset];
            }
        }
        _assets = assets;
    }
    
    _assetsurl = [jsonDictionary[@"assetsurl"] copy];
    _dcourl = [jsonDictionary[@"dcourl"] copy];
    
    PBMJsonDictionary * const linkJson = jsonDictionary[@"link"];
    if (linkJson) {
        // TODO: Handle (optional) link parsing error?
        _link = [[PBMNativeAdMarkupLink alloc] initWithJsonDictionary:linkJson error:nil];
    } else {
        PBMLogWarn(@"Required property 'link' is absent in jsonDict for nativeAd");
    }
    
    _imptrackers = [jsonDictionary[@"imptrackers"] copy];
    _jstracker = [jsonDictionary[@"jstracker"] copy];
    
    NSArray<PBMJsonDictionary *> * const rawTrackers = jsonDictionary[@"eventtrackers"];
    if (rawTrackers) {
        NSMutableArray<PBMNativeAdMarkupEventTracker *> * const trackers = [[NSMutableArray alloc]
                                                                            initWithCapacity:rawAssets.count];
        for (PBMJsonDictionary *nextRawTracker in rawTrackers) {
            NSError *trackerError = nil;
            PBMNativeAdMarkupEventTracker * const nextTracker = [[PBMNativeAdMarkupEventTracker alloc]
                                                                 initWithJsonDictionary:nextRawTracker
                                                                 error:&trackerError];
            // TODO: Handle 'trackerError'?
            if (nextTracker) {
                [trackers addObject:nextTracker];
            }
        }
        _eventtrackers = trackers;
    }
    
    _privacy = [jsonDictionary[@"privacy"] copy];
    _ext = jsonDictionary[@"ext"];
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    PBMNativeAdMarkup *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(PBMNativeAdMarkup *src) { return src.version; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.assets; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.assetsurl; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.dcourl; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.link; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.imptrackers; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.jstracker; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.eventtrackers; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.privacy; })
                && objComparator(^(PBMNativeAdMarkup *src) { return src.ext; })
                )
            );
}

@end
