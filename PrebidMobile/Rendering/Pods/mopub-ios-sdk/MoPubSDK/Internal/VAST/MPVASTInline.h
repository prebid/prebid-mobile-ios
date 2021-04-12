//
//  MPVASTInline.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTAdVerifications.h"
#import "MPVASTModel.h"

@class MPVASTCreative;

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTInline : MPVASTModel

/**
 Optional Viewability resources.
 */
@property (nonatomic, nullable, readonly) MPVASTAdVerifications *adVerifications;

/**
 Optional array of creatives associated with the inline ad.
*/
@property (nonatomic, nullable, readonly) NSArray<MPVASTCreative *> *creatives;

/**
 Optional array of error URLs.
 */
@property (nonatomic, nullable, readonly) NSArray<NSURL *> *errorURLs;

/**
 Optional extensions in the inline ad.
*/
@property (nonatomic, nullable, readonly) NSArray<NSDictionary *> *extensions;

/**
 Required impression URLs associated with the inline ad.
*/
@property (nonatomic, nullable, readonly) NSArray<NSURL *> *impressionURLs;

@end

NS_ASSUME_NONNULL_END
