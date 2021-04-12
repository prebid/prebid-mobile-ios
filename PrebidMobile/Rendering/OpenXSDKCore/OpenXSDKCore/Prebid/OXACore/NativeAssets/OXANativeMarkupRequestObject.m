//
//  OXANativeMarkupRequestObject.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeMarkupRequestObject.h"
#import "OXANativeMarkupRequestObject+Internal.h"

#import "OXANativeAsset+Internal.h"
#import "OXANativeEventTracker+Internal.h"

#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"

#import "NSNumber+OXAORTBNative.h"
#import "NSDictionary+OXAORTBNativeExt.h"

@interface OXANativeMarkupRequestObject ()
@property (nonatomic, strong) NSArray<OXANativeAsset *> *rawAssets;
@property (nonatomic, strong, nullable) NSString *rawVersion;
@property (nonatomic, strong, nullable) NSArray<OXANativeEventTracker *> *rawEventTrackers;
@end


@implementation OXANativeMarkupRequestObject

- (instancetype)initWithAssets:(NSArray<OXANativeAsset *> *)assets {
    if(!(self = [super init])) {
        return nil;
    }
    _assets = [assets copy];
    _version = @"1.2";
    return self;
}

// MARK: - Raw Property Accessors

- (NSArray<OXANativeAsset *> *)rawAssets {
    return _assets;
}

- (void)setRawAssets:(NSArray<OXANativeAsset *> *)rawAssets {
    _assets = rawAssets;
}

- (void)setExt:(nullable NSDictionary<NSString *, id> *)ext {
    _ext = ext;
}

- (void)setRawVersion:(NSString *)rawVersion {
    _version = rawVersion;
}

- (NSString *)rawVersion {
    return _version;
}

- (void)setRawEventTrackers:(NSArray<OXANativeEventTracker *> *)rawEventTrackers {
    _eventtrackers = rawEventTrackers;
}

- (NSArray<OXANativeEventTracker *> *)rawEventTrackers {
    return _eventtrackers;
}

// MARK: - OXAJsonCodable

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    return [OXMFunctions toStringJsonDictionary:self.jsonDictionary error:error];
}

- (nullable OXMJsonDictionary *)jsonDictionary {
    OXMMutableJsonDictionary * const json = [[OXMMutableJsonDictionary alloc] init];
    json[@"ver"] = self.version;
    json[@"context"] = self.context.integerNumber;
    json[@"contextsubtype"] = self.contextsubtype.integerNumber;
    json[@"plcmttype"] = self.plcmttype.integerNumber;
    json[@"seq"] = self.seq.integerNumber;
    json[@"assets"] = self.jsonAssets;
    json[@"plcmtcnt"] = self.plcmtcnt.integerNumber;
    json[@"aurlsupport"] = self.aurlsupport.integerNumber;
    json[@"durlsupport"] = self.durlsupport.integerNumber;
    json[@"eventtrackers"] = self.jsonTrackers;
    json[@"privacy"] = self.privacy.integerNumber;
    json[@"ext"] = self.ext;
    return json;
}

- (NSArray<OXMJsonDictionary *> *)jsonAssets {
    NSMutableArray<OXMJsonDictionary *> * const serializedAssets = [[NSMutableArray alloc] initWithCapacity:self.assets.count];
    for(OXANativeAsset *nextAsset in self.assets) {
        [serializedAssets addObject:nextAsset.jsonDictionary];
    }
    return serializedAssets;
}

- (nullable NSArray<OXMJsonDictionary *> *)jsonTrackers {
    if (!self.eventtrackers) {
        return nil;
    }
    NSMutableArray<OXMJsonDictionary *> * const serializedTrackers = [[NSMutableArray alloc] initWithCapacity:self.eventtrackers.count];
    for(OXANativeEventTracker *nextTracker in self.eventtrackers) {
        [serializedTrackers addObject:nextTracker.jsonDictionary];
    }
    return serializedTrackers;
}

// MARK: - Ext

- (BOOL)setExt:(nullable NSDictionary<NSString *, id> *)ext
         error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSError *localError = nil;
    OXMJsonDictionary * const newExt = [ext unserializedCopyWithError:&localError];
    if (error) {
        *error = localError;
    }
    if (localError) {
        return NO;
    }
    _ext = newExt;
    return YES;
}

// MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    OXANativeMarkupRequestObject * const clone = [[[self class] alloc] initWithAssets:@[]];
    clone.rawVersion = self.rawVersion;
    clone.context = self.context;
    clone.contextsubtype = self.contextsubtype;
    clone.plcmttype = self.plcmttype;
    clone.plcmtcnt = self.plcmtcnt;
    clone.seq = self.seq;
    clone.rawAssets = self.rawAssets;
    clone.aurlsupport = self.aurlsupport;
    clone.durlsupport = self.durlsupport;
    clone.rawEventTrackers = self.rawEventTrackers;
    clone.privacy = self.privacy;
    clone.ext = self.ext;
    return clone;
}

@end

