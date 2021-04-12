//
//  OXANativeAssetImage.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAssetImage.h"
#import "OXANativeAsset+Protected.h"
#import "NSNumber+OXAORTBNative.h"

@interface OXANativeAssetImage()
@property (nonatomic, strong, nullable) NSArray<NSString *> *storedMimeTypes; /// direct (non-copy) access to 'mimeTypes'
@end


@implementation OXANativeAssetImage

- (instancetype)init {
    if (!(self = [super initWithChildType:@"img"])) {
        return nil;
    }
    return self;
}

// MARK: - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    OXANativeAssetImage * const result = [[OXANativeAssetImage alloc] init];
    [self copyOptionalPropertiesInto:result];
    return result;
}

- (void)copyOptionalPropertiesInto:(OXANativeAsset *)clone {
    [super copyOptionalPropertiesInto:clone];
    if ([clone isKindOfClass:self.class]) {
        OXANativeAssetImage * const imageClone = (OXANativeAssetImage *)clone;
        imageClone.imageType = self.imageType;
        imageClone.width = self.width;
        imageClone.height = self.height;
        imageClone.widthMin = self.widthMin;
        imageClone.heightMin = self.heightMin;
        imageClone.storedMimeTypes = self.storedMimeTypes;
    }
}

- (NSArray<NSString *> *)storedMimeTypes {
    return _mimeTypes;
}

- (void)setStoredMimeTypes:(NSArray<NSString *> *)storedMimeTypes {
    _mimeTypes = storedMimeTypes;
}

// MARK: - Image Ext

- (NSDictionary<NSString *,id> *)imageExt {
    return self.childExt;
}

- (BOOL)setImageExt:(nullable NSDictionary<NSString *, id> *)imageExt
              error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    return [self setChildExt:imageExt error:error];
}

// MARK: - Protected

- (void)appendChildProperties:(OXMMutableJsonDictionary *)jsonDictionary {
    [super appendChildProperties:jsonDictionary];
    jsonDictionary[@"type"] = self.imageType.integerNumber;
    jsonDictionary[@"w"] = self.width.integerNumber;
    jsonDictionary[@"h"] = self.height.integerNumber;
    jsonDictionary[@"wmin"] = self.widthMin.integerNumber;
    jsonDictionary[@"hmin"] = self.heightMin.integerNumber;
    jsonDictionary[@"mimes"] = self.mimeTypes;
}

@end
