//
//  PBMNativeAdConfiguration.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdConfiguration.h"
#import "PBMNativeMarkupRequestObject+Internal.h"

@interface PBMNativeAdConfiguration()

@property (nonatomic, copy, nonnull) PBMNativeMarkupRequestObject *markupRequestObject;

@end

@implementation PBMNativeAdConfiguration

- (instancetype)initWithAssets:(NSArray<NativeAsset *> *)assets {
    if (!(self = [super init])) {
        return nil;
    }
    
    _markupRequestObject = [[PBMNativeMarkupRequestObject alloc] initWithAssets:assets];
    
    return self;
}

// MARK: - setters & getters

- (void)setVersion:(NSString * _Nullable)version {
    self.markupRequestObject.version = version;
}

- (NSString *)version {
    return self.markupRequestObject.version;
}

- (void)setContext:(PBMNativeContextType)context {
    self.markupRequestObject.context = context == PBMNativeContextType_Undefined ? nil : @(context);
}

- (PBMNativeContextType)context {
    return self.markupRequestObject.context.integerValue;
}

- (void)setContextsubtype:(PBMNativeContextSubtype)contextsubtype {
    self.markupRequestObject.contextsubtype = contextsubtype == PBMNativeContextSubtype_Undefined ? nil : @(contextsubtype);
}

- (PBMNativeContextSubtype)contextsubtype {
    return self.markupRequestObject.contextsubtype.integerValue;
}

- (void)setPlcmttype:(PBMNativePlacementType)plcmttype {
    self.markupRequestObject.plcmttype = plcmttype == PBMNativePlacementType_Undefined ? nil : @(plcmttype);
}

- (void)setSeq:(NSNumber *)seq {
    self.markupRequestObject.seq = seq.integerValue >= 0 ? seq : nil;
}

- (NSNumber *)seq {
    return self.markupRequestObject.seq;
}

- (void)setAssets:(NSArray<NativeAsset *> *)assets {
    self.markupRequestObject.assets = assets;
}

- (NSArray<NativeAsset *> *)assets {
    return self.markupRequestObject.assets;
}

- (void)setEventtrackers:(NSArray<PBMNativeEventTracker *> *)eventtrackers {
    self.markupRequestObject.eventtrackers = eventtrackers;
}

- (NSArray<PBMNativeEventTracker *> *)eventtrackers {
    return self.markupRequestObject.eventtrackers;
}

- (void)setPrivacy:(NSNumber *)privacy {
    self.markupRequestObject.privacy = privacy;
}

-(NSNumber *)privacy {
    return self.markupRequestObject.privacy;
}

- (BOOL)setExt:(nullable NSDictionary<NSString *, id> *)ext
         error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self.markupRequestObject setExt:ext error:error];
}

- (NSDictionary<NSString *, id> *)ext {
    return self.markupRequestObject.ext;
}

// MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    PBMNativeAdConfiguration * clone = [[[self class] alloc] init];
    clone.markupRequestObject = self.markupRequestObject;
    clone.nativeStylesCreative = self.nativeStylesCreative;
    return clone;
}

@end
