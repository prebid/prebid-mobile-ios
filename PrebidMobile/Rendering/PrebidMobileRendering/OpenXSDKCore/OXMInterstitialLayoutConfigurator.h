//
//  OXMInterstitialLayoutConfigurator.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMAdConfiguration.h"
#import "OXMInterstitialDisplayProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXMInterstitialLayoutConfigurator : NSObject

+ (BOOL)isPortrait:(CGSize)size;
+ (BOOL)isLandscape:(CGSize)size;
+ (OXMInterstitialLayout)calculateLayoutFromSize:(CGSize)size;
+ (void)configurePropertiesWithAdConfiguration:(OXMAdConfiguration *)adConfiguration displayProperties:(OXMInterstitialDisplayProperties *)displayProperties;

@end

NS_ASSUME_NONNULL_END
