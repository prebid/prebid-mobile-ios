/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
