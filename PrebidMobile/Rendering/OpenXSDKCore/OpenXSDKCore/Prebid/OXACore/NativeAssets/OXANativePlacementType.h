//
//  OXANativePlacementType.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXANativePlacementType) {
    OXANativePlacementType_Undefined = 0,
    OXANativePlacementType_FeedGridListing = 1, /// feed/grid/listing/carousel.
    OXANativePlacementType_AtomicUnit = 2, /// In the atomic unit of the content - IE in the article page or single image page
    OXANativePlacementType_OutsideCoreContent = 3, /// Outside the core content - for example in the ads section on the right rail, as a banner-style placement near the content, etc.
    OXANativePlacementType_RecommendationWidget = 4, /// Recommendation widget, most commonly presented below the article content.
    
    OXANativePlacementType_ExchangeSpecific = 500, /// To be defined by the exchange.
};
