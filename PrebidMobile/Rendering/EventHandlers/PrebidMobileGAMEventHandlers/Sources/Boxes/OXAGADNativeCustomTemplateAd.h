//
//  OXAGADNativeCustomTemplateAd.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class GADNativeCustomTemplateAd;

NS_ASSUME_NONNULL_BEGIN

@interface OXAGADNativeCustomTemplateAd : NSObject

@property (nonatomic, class, readonly) BOOL classesFound;
@property (nonatomic, strong, readonly) NSObject *boxedAd;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCustomTemplateAd:(GADNativeCustomTemplateAd *)customTemplateAd NS_DESIGNATED_INITIALIZER;

/// Returns the string corresponding to the specified key or nil if the string is not available.
- (nullable NSString *)stringForKey:(nonnull NSString *)key;

@end

NS_ASSUME_NONNULL_END
