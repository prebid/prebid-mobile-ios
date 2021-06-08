//
//  NativePlacementType.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public enum NativePlacementType : Int {
    
    case undefined              = 0
    case feedGridListing        = 1 /// feed/grid/listing/carousel.
    case atomicUnit             = 2 /// In the atomic unit of the content - IE in the article page or single image page
    case outsideCoreContent     = 3 /// Outside the core content - for example in the ads section on the right rail, as a banner-style placement near the content, etc.
    case recommendationWidget   = 4 /// Recommendation widget, most commonly presented below the article content.
    
    case exchangeSpecific       = 500 /// To be defined by the exchange.
};
