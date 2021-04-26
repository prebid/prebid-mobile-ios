//
//  PBMNativeContextSubtype.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBMNativeContextSubtype) {
    PBMNativeContextSubtype_Undefined = 0,
    PBMNativeContextSubtype_GeneralOrMixed = 10, /// General or mixed content.
    PBMNativeContextSubtype_Article = 11, /// Primarily article content (which of course could include images, etc as part of the article)
    PBMNativeContextSubtype_Video = 12, /// Primarily video content
    PBMNativeContextSubtype_Audio = 13, /// Primarily audio content
    PBMNativeContextSubtype_Image = 14, /// Primarily image content
    PBMNativeContextSubtype_UserGenerated = 15, /// User-generated content - forums, comments, etc
    
    PBMNativeContextSubtype_Social = 20, /// General social content such as a general social network
    PBMNativeContextSubtype_Email = 21, /// Primarily email content
    PBMNativeContextSubtype_Chat = 22, /// Primarily chat,/IM content,
    
    PBMNativeContextSubtype_SellingProducts = 30, /// Content focused on selling products, whether digital or physical
    PBMNativeContextSubtype_ApplicationStore = 31, /// Application store/marketplace
    PBMNativeContextSubtype_ProductReviews = 32, /// Product reviews site primarily (which may sell product secondarily)
    
    PBMNativeContextSubtype_ExchangeSpecific = 500, /// To be defined by the exchange.
};
