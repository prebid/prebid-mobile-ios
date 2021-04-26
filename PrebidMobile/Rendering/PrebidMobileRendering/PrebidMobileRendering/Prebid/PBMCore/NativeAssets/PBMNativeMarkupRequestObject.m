//
//  PBMNativeMarkupRequestObject.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeMarkupRequestObject.h"
#import "PBMNativeMarkupRequestObject+Internal.h"

#import "PBMNativeAsset+Internal.h"
#import "PBMNativeEventTracker+Internal.h"

#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"

#import "NSNumber+PBMORTBNative.h"
#import "NSDictionary+PBMORTBNativeExt.h"

@interface PBMNativeMarkupRequestObject ()
@property (nonatomic, strong) NSArray<PBMNativeAsset *> *rawAssets;
@property (nonatomic, strong, nullable) NSString *rawVersion;
@property (nonatomic, strong, nullable) NSArray<PBMNativeEventTracker *> *rawEventTrackers;
@end


@implementation PBMNativeMarkupRequestObject

- (instancetype)initWithAssets:(NSArray<PBMNativeAsset *> *)assets {
    if(!(self = [super init])) {
        return nil;
    }
    _assets = [assets copy];
    _version = @"1.2";
    return self;
}

// MARK: - Raw Property Accessors

- (NSArray<PBMNativeAsset *> *)rawAssets {
    return _assets;
}

- (void)setRawAssets:(NSArray<PBMNativeAsset *> *)rawAssets {
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

- (void)setRawEventTrackers:(NSArray<PBMNativeEventTracker *> *)rawEventTrackers {
    _eventtrackers = rawEventTrackers;
}

- (NSArray<PBMNativeEventTracker *> *)rawEventTrackers {
    return _eventtrackers;
}

// MARK: - PBMJsonCodable

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    return [PBMFunctions toStringJsonDictionary:self.jsonDictionary error:error];
}

- (nullable PBMJsonDictionary *)jsonDictionary {
    PBMMutableJsonDictionary * const json = [[PBMMutableJsonDictionary alloc] init];
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

- (NSArray<PBMJsonDictionary *> *)jsonAssets {
    NSMutableArray<PBMJsonDictionary *> * const serializedAssets = [[NSMutableArray alloc] initWithCapacity:self.assets.count];
    for(PBMNativeAsset *nextAsset in self.assets) {
        [serializedAssets addObject:nextAsset.jsonDictionary];
    }
    return serializedAssets;
}

- (nullable NSArray<PBMJsonDictionary *> *)jsonTrackers {
    if (!self.eventtrackers) {
        return nil;
    }
    NSMutableArray<PBMJsonDictionary *> * const serializedTrackers = [[NSMutableArray alloc] initWithCapacity:self.eventtrackers.count];
    for(PBMNativeEventTracker *nextTracker in self.eventtrackers) {
        [serializedTrackers addObject:nextTracker.jsonDictionary];
    }
    return serializedTrackers;
}

// MARK: - Ext

- (BOOL)setExt:(nullable NSDictionary<NSString *, id> *)ext
         error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSError *localError = nil;
    PBMJsonDictionary * const newExt = [ext unserializedCopyWithError:&localError];
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
    PBMNativeMarkupRequestObject * const clone = [[[self class] alloc] initWithAssets:@[]];
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

