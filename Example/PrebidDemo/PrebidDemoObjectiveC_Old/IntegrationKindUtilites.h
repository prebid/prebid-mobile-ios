//
//  IntegrationKindUtilites.h
//  PrebidDemoObjectiveC
//
//  Created by Yuriy Velichko on 15.11.2021.
//  Copyright © 2021 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntegrationKind.h"

NS_ASSUME_NONNULL_BEGIN

@interface IntegrationKindUtilites : NSObject

+ (NSArray *)IntegrationKindAllCases;
+ (NSDictionary *)IntegrationKindDescr;

+ (NSArray *)IntegrationAdFormatAllCases;
+ (NSDictionary *)IntegrationAdFormatDescr;

+ (NSArray *)IntegrationAdFormatFor:(IntegrationKind) integrationKind;

+ (NSArray *)IntegrationAdFormatOriginal;
+ (NSArray *)IntegrationAdFormatRendering;
+ (NSArray *)IntegrationAdFormatRenderingInApp;

+ (BOOL)isRenderingIntegrationKind:(IntegrationKind) integrationKind;
+ (BOOL)isRenderingInApp:(IntegrationKind) integrationKind;

@end

NS_ASSUME_NONNULL_END
