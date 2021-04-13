//
//  OXADataAssetType.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, OXADataAssetType) {
    OXADataAssetType_Undefined = 0,
    OXADataAssetType_Sponsored = 1, /// Sponsored By message where response should contain the brand name of the sponsor.
    OXADataAssetType_Desc = 2, /// Descriptive text associated with the product or service being advertised. Longer length of text in response may be truncated or ellipsed by the exchange.
    OXADataAssetType_Rating = 3, /// Rating of the product being offered to the user. For example an app’s rating in an app store from 0-5.
    OXADataAssetType_Likes = 4, /// Number of social ratings or “likes” of the product being offered to the user.
    OXADataAssetType_Downloads = 5, /// Number downloads/installs of this product
    OXADataAssetType_Price = 6, /// Price for product / app / in-app purchase. Value should include currency symbol in localised format.
    OXADataAssetType_SalePrice = 7, /// Sale price that can be used together with price to indicate a discounted price compared to a regular price. Value should include currency symbol in localised format.
    OXADataAssetType_Phone = 8, /// Phone number
    OXADataAssetType_Address = 9, /// Address
    OXADataAssetType_Desc2 = 10, /// Additional descriptive text associated text with the product or service being advertised
    OXADataAssetType_DisplayURL = 11, /// Display URL for the text ad. To be used when sponsoring entity doesn’t own the content. IE sponsored by BRAND on SITE (where SITE is transmitted in this field).
    OXADataAssetType_CTAText = 12, /// CTA description - descriptive text describing a ‘call to action’ button for the destination URL.
    
    OXADataAssetType_Custom = 500, /// Reserved for Exchange specific usage numbered above 500
};
