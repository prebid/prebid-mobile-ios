//
//  MPVASTWrapper.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVASTAdVerifications.h"
#import "MPVASTModel.h"

@class MPVASTCreative;
@class MPVASTResponse;

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTWrapper : MPVASTModel

/**
 Optional Viewability resources.
 */
@property (nonatomic, nullable, readonly) MPVASTAdVerifications *adVerifications;

/**
 Optional array of creatives associated with the wrapper.
 */
@property (nonatomic, nullable, readonly) NSArray<MPVASTCreative *> *creatives;

/**
 Optional array of error URLs.
 */
@property (nonatomic, nullable, readonly) NSArray<NSURL *> *errorURLs;

/**
 Optional extensions in the wrapper.
 */
@property (nonatomic, nullable, readonly) NSArray<NSDictionary *> *extensions;

/**
 Required impression URLs associated with the wrapper.
 */
@property (nonatomic, nullable, readonly) NSArray<NSURL *> *impressionURLs;

/**
 Required URL of the next VAST response to fetch.
 */
@property (nonatomic, nullable, readonly) NSURL *VASTAdTagURI;

#pragma mark - Unwrapped VAST Response

/**
 The result of attempting to unwrap this VAST wrapper.
 */
@property (nonatomic, nullable, readonly) MPVASTResponse *wrappedVASTResponse;

@end

NS_ASSUME_NONNULL_END
