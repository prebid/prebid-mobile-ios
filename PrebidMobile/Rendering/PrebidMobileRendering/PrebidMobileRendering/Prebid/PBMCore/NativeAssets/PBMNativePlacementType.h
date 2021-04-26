//
//  PBMNativePlacementType.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBMNativePlacementType) {
    PBMNativePlacementType_Undefined = 0,
    PBMNativePlacementType_FeedGridListing = 1, /// feed/grid/listing/carousel.
    PBMNativePlacementType_AtomicUnit = 2, /// In the atomic unit of the content - IE in the article page or single image page
    PBMNativePlacementType_OutsideCoreContent = 3, /// Outside the core content - for example in the ads section on the right rail, as a banner-style placement near the content, etc.
    PBMNativePlacementType_RecommendationWidget = 4, /// Recommendation widget, most commonly presented below the article content.
    
    PBMNativePlacementType_ExchangeSpecific = 500, /// To be defined by the exchange.
};
