//
//  MPVASTLinearAd.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTModel.h"
#import "MPVideoEvent.h"

@class MPVASTDurationOffset;
@class MPVASTIndustryIcon;
@class MPVASTMediaFile;
@class MPVASTTrackingEvent;

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTLinearAd : MPVASTModel

/**
 Optional click through URL.
 */
@property (nonatomic, nullable, readonly) NSURL *clickThroughURL;

/**
 Optional array of click tracking URLs.
 */
@property (nonatomic, nullable, readonly) NSArray<NSURL *> *clickTrackingURLs;

/**
 Optional array of custom video click URLs.
 */
@property (nonatomic, nullable, readonly) NSArray<NSURL *> *customClickURLs;

/**
 Required duration of the Linear ad.
 */
@property (nonatomic, readonly) NSTimeInterval duration;

/**
 Optional array of industry icons.
 */
@property (nonatomic, nullable, readonly) NSArray<MPVASTIndustryIcon *> *industryIcons;

/**
 Array of media files associated with the Linear ad. This may be `nil` if there are no media files.
 */
@property (nonatomic, nullable, readonly) NSArray<MPVASTMediaFile *> *mediaFiles;

/**
 Optional time value that identifies when skip controls are made available to the end user.
 */
@property (nonatomic, nullable, readonly) MPVASTDurationOffset *skipOffset;

/**
 Optional table of tracking events for the Linear ad. This will be `nil` if there are no tracking events.
 */
@property (nonatomic, nullable, readonly) NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *trackingEvents;

@end

NS_ASSUME_NONNULL_END
