//
//  IntegrationKind.h
//  PrebidDemo
//
//  Created by Yuriy Velichko on 12.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#ifndef IntegrationKind_h
#define IntegrationKind_h

typedef NS_ENUM(NSUInteger, IntegrationKind) {
    IntegrationKind_OriginalGAM,
    
    IntegrationKind_InApp,
    IntegrationKind_RenderingGAM,
    IntegrationKind_RenderingAdMob,
    IntegrationKind_RenderingMAX
};

typedef NS_ENUM(NSUInteger, IntegrationAdFormat) {
    IntegrationAdFormat_Banner,
    IntegrationAdFormat_BannerVideo,
    
    IntegrationAdFormat_Interstitial,
    IntegrationAdFormat_InterstitialVideo,
    IntegrationAdFormat_InterstitialVideoVertical,
    IntegrationAdFormat_InterstitialVideoLandscape,
    
    IntegrationAdFormat_NativeInApp,
    
    IntegrationAdFormat_Rewarded
};


#endif /* IntegrationKind_h */

