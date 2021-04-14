//
//  OXANativeAdConfiguration.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdConfiguration.h"
#import "OXANativeMarkupRequestObject+Internal.h"

@interface OXANativeAdConfiguration()

@property (nonatomic, copy, nonnull) OXANativeMarkupRequestObject *markupRequestObject;

@end

@implementation OXANativeAdConfiguration

- (instancetype)initWithAssets:(NSArray<OXANativeAsset *> *)assets {
    if (!(self = [super init])) {
        return nil;
    }
    
    _markupRequestObject = [[OXANativeMarkupRequestObject alloc] initWithAssets:assets];
    
    return self;
}

// MARK: - setters & getters

- (void)setVersion:(NSString * _Nullable)version {
    self.markupRequestObject.version = version;
}

- (NSString *)version {
    return self.markupRequestObject.version;
}

- (void)setContext:(OXANativeContextType)context {
    self.markupRequestObject.context = context == OXANativeContextType_Undefined ? nil : @(context);
}

- (OXANativeContextType)context {
    return self.markupRequestObject.context.integerValue;
}

- (void)setContextsubtype:(OXANativeContextSubtype)contextsubtype {
    self.markupRequestObject.contextsubtype = contextsubtype == OXANativeContextSubtype_Undefined ? nil : @(contextsubtype);
}

- (OXANativeContextSubtype)contextsubtype {
    return self.markupRequestObject.contextsubtype.integerValue;
}

- (void)setPlcmttype:(OXANativePlacementType)plcmttype {
    self.markupRequestObject.plcmttype = plcmttype == OXANativePlacementType_Undefined ? nil : @(plcmttype);
}

- (void)setSeq:(NSNumber *)seq {
    self.markupRequestObject.seq = seq.integerValue >= 0 ? seq : nil;
}

- (NSNumber *)seq {
    return self.markupRequestObject.seq;
}

- (void)setAssets:(NSArray<OXANativeAsset *> *)assets {
    self.markupRequestObject.assets = assets;
}

- (NSArray<OXANativeAsset *> *)assets {
    return self.markupRequestObject.assets;
}

- (void)setEventtrackers:(NSArray<OXANativeEventTracker *> *)eventtrackers {
    self.markupRequestObject.eventtrackers = eventtrackers;
}

- (NSArray<OXANativeEventTracker *> *)eventtrackers {
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
    OXANativeAdConfiguration * clone = [[[self class] alloc] init];
    clone.markupRequestObject = self.markupRequestObject;
    clone.nativeStylesCreative = self.nativeStylesCreative;
    return clone;
}

@end
