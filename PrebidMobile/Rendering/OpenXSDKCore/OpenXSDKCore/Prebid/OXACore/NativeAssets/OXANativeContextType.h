//
//  OXANativeContextType.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXANativeContextType) {
    OXANativeContextType_Undefined = 0,      
    OXANativeContextType_ContentCentric = 1, /// Content-centric context such as newsfeed, article, image gallery, video gallery, or similar.
    OXANativeContextType_SocialCentric = 2,  /// Social-centric context such as social network feed, email, chat, or similar.
    OXANativeContextType_Product = 3,        /// Product context such as product listings, details, recommendations, reviews, or similar.
    
    OXANativeContextType_ExchangeSpecific = 500, /// To be defined by the exchange.
};
