//
//  PBMNativeAssetImage.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAssetImage.h"
#import "PBMNativeAsset+Protected.h"
#import "NSNumber+PBMORTBNative.h"

@interface PBMNativeAssetImage()
@property (nonatomic, strong, nullable) NSArray<NSString *> *storedMimeTypes; /// direct (non-copy) access to 'mimeTypes'
@end


@implementation PBMNativeAssetImage

- (instancetype)init {
    if (!(self = [super initWithChildType:@"img"])) {
        return nil;
    }
    return self;
}

// MARK: - NSCopying

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    PBMNativeAssetImage * const result = [[PBMNativeAssetImage alloc] init];
    [self copyOptionalPropertiesInto:result];
    return result;
}

- (void)copyOptionalPropertiesInto:(PBMNativeAsset *)clone {
    [super copyOptionalPropertiesInto:clone];
    if ([clone isKindOfClass:self.class]) {
        PBMNativeAssetImage * const imageClone = (PBMNativeAssetImage *)clone;
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

- (void)appendChildProperties:(PBMMutableJsonDictionary *)jsonDictionary {
    [super appendChildProperties:jsonDictionary];
    jsonDictionary[@"type"] = self.imageType.integerNumber;
    jsonDictionary[@"w"] = self.width.integerNumber;
    jsonDictionary[@"h"] = self.height.integerNumber;
    jsonDictionary[@"wmin"] = self.widthMin.integerNumber;
    jsonDictionary[@"hmin"] = self.heightMin.integerNumber;
    jsonDictionary[@"mimes"] = self.mimeTypes;
}

@end
