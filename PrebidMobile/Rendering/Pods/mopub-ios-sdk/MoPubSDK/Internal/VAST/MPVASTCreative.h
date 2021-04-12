//
//  MPVASTCreative.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTModel.h"

@class MPVASTLinearAd;
@class MPVASTCompanionAd;

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTCreative : MPVASTModel

/**
 A string used to identify the ad server that provides the creative.
 */
@property (nonatomic, nullable, copy, readonly) NSString *identifier;

/**
 A number representing the numerical order in which each sequenced creative within
 an ad should play.
 */
@property (nonatomic, nullable, copy, readonly) NSString *sequence;

/**
 Used to provide the ad server’s unique identifier for the creative.
 */
@property (nonatomic, nullable, copy, readonly) NSString *adID;

/**
 The media and properties describing the rendering of the creative.
 */
@property (nonatomic, nullable, strong, readonly) MPVASTLinearAd *linearAd;

/**
 Companion ads associated with the creative.
 */
@property (nonatomic, nullable, strong, readonly) NSArray<MPVASTCompanionAd *> *companionAds;

@end

NS_ASSUME_NONNULL_END
