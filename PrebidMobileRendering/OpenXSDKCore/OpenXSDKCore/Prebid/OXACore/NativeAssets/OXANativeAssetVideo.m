//
//  OXANativeAssetVideo.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAssetVideo.h"
#import "OXANativeAsset+Protected.h"
#import "NSNumber+OXAORTBNative.h"

@implementation OXANativeAssetVideo

- (instancetype)initWithMimeTypes:(NSArray<NSString *> *)mimeTypes
                      minDuration:(NSInteger)minDuration
                      maxDuration:(NSInteger)maxDuration
                        protocols:(NSArray<NSNumber *> *)protocols
{
    if (!(self = [super initWithChildType:@"video"])) {
        return nil;
    }
    _mimeTypes = [mimeTypes copy];
    _minDuration = minDuration;
    _maxDuration = maxDuration;
    _protocols = [protocols copy];
    return self;
}

// MARK: - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    OXANativeAssetVideo * const result = [[OXANativeAssetVideo alloc] initWithMimeTypes:self.mimeTypes
                                                                            minDuration:self.minDuration
                                                                            maxDuration:self.maxDuration
                                                                              protocols:self.protocols];
    [self copyOptionalPropertiesInto:result];
    return result;
}

// MARK: - Video Ext

- (NSDictionary<NSString *,id> *)videoExt {
    return self.childExt;
}

- (BOOL)setVideoExt:(nullable NSDictionary<NSString *, id> *)videoExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    return [self setChildExt:videoExt error:error];
}

// MARK: - Protected

- (void)appendChildProperties:(OXMMutableJsonDictionary *)jsonDictionary {
    [super appendChildProperties:jsonDictionary];
    jsonDictionary[@"mimes"] = self.mimeTypes;
    jsonDictionary[@"minDuration"] = @(self.minDuration);
    jsonDictionary[@"maxDuration"] = @(self.maxDuration);
    if (self.protocols) {
        NSMutableArray * const newProtocols = [[NSMutableArray alloc] initWithCapacity:self.protocols.count];
        for(NSNumber *nextProtocol in self.protocols) {
            [newProtocols addObject:nextProtocol.integerNumber];
        }
        jsonDictionary[@"protocols"] = newProtocols;
    }
}

@end
