//
//  OXANativeContextSubtype.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXANativeContextSubtype) {
    OXANativeContextSubtype_Undefined = 0,
    OXANativeContextSubtype_GeneralOrMixed = 10, /// General or mixed content.
    OXANativeContextSubtype_Article = 11, /// Primarily article content (which of course could include images, etc as part of the article)
    OXANativeContextSubtype_Video = 12, /// Primarily video content
    OXANativeContextSubtype_Audio = 13, /// Primarily audio content
    OXANativeContextSubtype_Image = 14, /// Primarily image content
    OXANativeContextSubtype_UserGenerated = 15, /// User-generated content - forums, comments, etc
    
    OXANativeContextSubtype_Social = 20, /// General social content such as a general social network
    OXANativeContextSubtype_Email = 21, /// Primarily email content
    OXANativeContextSubtype_Chat = 22, /// Primarily chat,/IM content,
    
    OXANativeContextSubtype_SellingProducts = 30, /// Content focused on selling products, whether digital or physical
    OXANativeContextSubtype_ApplicationStore = 31, /// Application store/marketplace
    OXANativeContextSubtype_ProductReviews = 32, /// Product reviews site primarily (which may sell product secondarily)
    
    OXANativeContextSubtype_ExchangeSpecific = 500, /// To be defined by the exchange.
};
