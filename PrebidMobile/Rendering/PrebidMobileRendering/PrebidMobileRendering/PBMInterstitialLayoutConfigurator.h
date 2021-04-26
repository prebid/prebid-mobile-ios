//
//  PBMInterstitialLayoutConfigurator.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMAdConfiguration.h"
#import "PBMInterstitialDisplayProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMInterstitialLayoutConfigurator : NSObject

+ (BOOL)isPortrait:(CGSize)size;
+ (BOOL)isLandscape:(CGSize)size;
+ (PBMInterstitialLayout)calculateLayoutFromSize:(CGSize)size;
+ (void)configurePropertiesWithAdConfiguration:(PBMAdConfiguration *)adConfiguration displayProperties:(PBMInterstitialDisplayProperties *)displayProperties;

@end

NS_ASSUME_NONNULL_END
