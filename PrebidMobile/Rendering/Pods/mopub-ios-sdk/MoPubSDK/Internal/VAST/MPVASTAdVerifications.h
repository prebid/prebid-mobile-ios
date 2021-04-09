//
//  MPVASTAdVerifications.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTModel.h"
#import "MPVASTVerification.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Viewability measurement resources for the VAST creative.
 */
@interface MPVASTAdVerifications : MPVASTModel
/**
 Optional list of verification resources associated with the VAST creative.
 */
@property (nonatomic, readonly) NSArray<MPVASTVerification *> *verifications;   // optional
@end

NS_ASSUME_NONNULL_END
