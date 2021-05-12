//
//  MPVASTResponse.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTModel.h"

#import "MPVASTAd.h"
#import "MPVASTCompanionAd.h"
#import "MPVASTCreative.h"
#import "MPVASTDurationOffset.h"
#import "MPVASTIndustryIcon.h"
#import "MPVASTInline.h"
#import "MPVASTLinearAd.h"
#import "MPVASTMediaFile.h"
#import "MPVASTResource.h"
#import "MPVASTTrackingEvent.h"
#import "MPVASTWrapper.h"

NS_ASSUME_NONNULL_BEGIN

/**
 VAST ad response representing the root of the VAST document.
 */
@interface MPVASTResponse : MPVASTModel
/**
 Available ads.
 */
@property (nonatomic, nullable, readonly) NSArray<MPVASTAd *> *ads;

/**
 Error tracking URLs to fire upon receiving a "no ad" response.
 */
@property (nonatomic, nullable, readonly) NSArray<NSURL *> *errorURLs;

/**
 VAST document version.
 */
@property (nonatomic, nullable, copy, readonly) NSString *version;

@end

NS_ASSUME_NONNULL_END
