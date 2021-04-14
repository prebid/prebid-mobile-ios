//
//  OXANativeAdMarkup.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdMarkup.h"

#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"

#import "OXMLog.h"

@implementation OXANativeAdMarkup

- (instancetype)initWithLink:(OXANativeAdMarkupLink *)link {
    if (!(self = [super init])) {
        return nil;
    }
    _link = link;
    return self;
}

- (instancetype)initWithJsonString:(NSString *)jsonString error:(NSError * _Nullable __autoreleasing *)error {
    NSError *localError = nil;
    OXMJsonDictionary * const jsonDic = [OXMFunctions dictionaryFromJSONString:jsonString error:&localError];
    if (!jsonDic) {
        if (error) {
            *error = localError;
        }
        return nil;
    }
    return [self initWithJsonDictionary:jsonDic error:error];
}

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary
                                 error:(NSError * _Nullable __autoreleasing *)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _version = [jsonDictionary[@"ver"] copy];
    
    NSArray<OXMJsonDictionary *> * const rawAssets = jsonDictionary[@"assets"];
    if (rawAssets) {
        NSMutableArray<OXANativeAdMarkupAsset *> * const assets = [[NSMutableArray alloc] initWithCapacity:rawAssets.count];
        for (OXMJsonDictionary *nextRawAsset in rawAssets) {
            NSError *assetError = nil;
            OXANativeAdMarkupAsset * const nextAsset = [[OXANativeAdMarkupAsset alloc]
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
    
    OXMJsonDictionary * const linkJson = jsonDictionary[@"link"];
    if (linkJson) {
        // TODO: Handle (optional) link parsing error?
        _link = [[OXANativeAdMarkupLink alloc] initWithJsonDictionary:linkJson error:nil];
    } else {
        OXMLogWarn(@"Required property 'link' is absent in jsonDict for nativeAd");
    }
    
    _imptrackers = [jsonDictionary[@"imptrackers"] copy];
    _jstracker = [jsonDictionary[@"jstracker"] copy];
    
    NSArray<OXMJsonDictionary *> * const rawTrackers = jsonDictionary[@"eventtrackers"];
    if (rawTrackers) {
        NSMutableArray<OXANativeAdMarkupEventTracker *> * const trackers = [[NSMutableArray alloc]
                                                                            initWithCapacity:rawAssets.count];
        for (OXMJsonDictionary *nextRawTracker in rawTrackers) {
            NSError *trackerError = nil;
            OXANativeAdMarkupEventTracker * const nextTracker = [[OXANativeAdMarkupEventTracker alloc]
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
    OXANativeAdMarkup *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(OXANativeAdMarkup *src) { return src.version; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.assets; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.assetsurl; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.dcourl; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.link; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.imptrackers; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.jstracker; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.eventtrackers; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.privacy; })
                && objComparator(^(OXANativeAdMarkup *src) { return src.ext; })
                )
            );
}

@end
