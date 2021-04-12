//
//  MPVASTJavaScriptResource.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTJavaScriptResource : MPVASTModel
@property (nonatomic, copy, readonly) NSString *apiFramework;   // required
@property (nonatomic, copy, readonly) NSURL *resourceUrl;       // required
@end

NS_ASSUME_NONNULL_END
