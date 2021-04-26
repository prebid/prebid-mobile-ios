//
//  PBMVastParser.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMVastResponse;
@class PBMVastInlineAd;
@class PBMVastWrapperAd;
@class PBMVastAbstractAd;
@class PBMVastCreativeAbstract;
@class PBMVideoVerificationParameters;
@class PBMVideoVerificationResource;

@interface PBMVastParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong, nullable) PBMVastResponse *parsedResponse;

@property (nonatomic, copy, nullable) NSString *currentElementContext;

@property (nonatomic, copy, nonnull) NSString *currentElementContent;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *currentElementAttributes;
@property (nonatomic, copy, nonnull) NSString *currentElementName;
@property (nonatomic, strong, nonnull) NSMutableArray<NSString *> *elementPath;

//Ad
@property (nonatomic, strong, nullable) PBMVastAbstractAd *ad;
@property (nonatomic, strong, nullable) PBMVastInlineAd *inlineAd;
@property (nonatomic, strong, nullable) PBMVastWrapperAd *wrapperAd;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *adAttributes;

@property (nonatomic, strong, nullable) PBMVideoVerificationParameters *verificationParameter;
@property (nonatomic, strong, nullable) PBMVideoVerificationResource *verificationResource;

//Creative
@property (nonatomic, strong, nullable) PBMVastCreativeAbstract *creative;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *creativeAttributes;

- (nullable PBMVastResponse *)parseAdsResponse:(nonnull NSData *)data;

@end
