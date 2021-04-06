//
//  OXMInterstitialLayout.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Determines the type of interstitial layout
 */
typedef NS_ENUM(NSInteger, OXMInterstitialLayout) {
    OXMInterstitialLayoutUndefined,
    OXMInterstitialLayoutPortrait,
    OXMInterstitialLayoutLandscape,
    OXMInterstitialLayoutAspectRatio,
};
