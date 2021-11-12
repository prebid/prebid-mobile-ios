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
    IntegrationKind_Undefined = 0,
    
    IntegrationKind_InApp,
    IntegrationKind_RenderingGAM,
    IntegrationKind_RenderingMoPub
};

typedef NS_ENUM(NSUInteger, AdFormat) {
    AdFormat_Display,
    AdFormat_Video
};


#endif /* IntegrationKind_h */
