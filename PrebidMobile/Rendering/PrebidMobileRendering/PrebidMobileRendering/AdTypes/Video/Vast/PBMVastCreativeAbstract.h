//
//  PBMVastCreativeAbstract.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMVastAbstractAd;

@interface PBMVastCreativeAbstract : NSObject

@property (nonatomic, copy, nullable) NSString *identifier     NS_SWIFT_NAME(id);
@property (nonatomic, copy, nullable) NSString *adId           NS_SWIFT_NAME(AdId);
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, copy, nullable) NSString *adParameters;

@end
