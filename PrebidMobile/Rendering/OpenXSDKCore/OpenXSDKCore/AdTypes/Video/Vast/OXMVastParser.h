//
//  OXMVastParser.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMVastResponse;
@class OXMVastInlineAd;
@class OXMVastWrapperAd;
@class OXMVastAbstractAd;
@class OXMVastCreativeAbstract;
@class OXMVideoVerificationParameters;
@class OXMVideoVerificationResource;

@interface OXMVastParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong, nullable) OXMVastResponse *parsedResponse;

@property (nonatomic, copy, nullable) NSString *currentElementContext;

@property (nonatomic, copy, nonnull) NSString *currentElementContent;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *currentElementAttributes;
@property (nonatomic, copy, nonnull) NSString *currentElementName;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *elementPath;

//Ad
@property (nonatomic, strong, nullable) OXMVastAbstractAd *ad;
@property (nonatomic, strong, nullable) OXMVastInlineAd *inlineAd;
@property (nonatomic, strong, nullable) OXMVastWrapperAd *wrapperAd;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *adAttributes;

@property (nonatomic, strong, nullable) OXMVideoVerificationParameters *verificationParameter;
@property (nonatomic, strong, nullable) OXMVideoVerificationResource *verificationResource;

//Creative
@property (nonatomic, strong, nullable) OXMVastCreativeAbstract *creative;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *creativeAttributes;

- (nullable OXMVastResponse *)parseAdsResponse:(nonnull NSData *)data;

@end
