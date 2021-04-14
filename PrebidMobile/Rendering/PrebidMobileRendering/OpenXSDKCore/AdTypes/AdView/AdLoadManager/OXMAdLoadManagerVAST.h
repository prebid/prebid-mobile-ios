//
//  OXMAdLoadManagerVAST.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdLoadManagerBase.h"
@class OXMAdRequestResponseVAST;

NS_ASSUME_NONNULL_BEGIN
@interface OXMAdLoadManagerVAST : OXMAdLoadManagerBase

- (void)loadFromString:(NSString *)vastString;
- (void)requestCompletedSuccess:(OXMAdRequestResponseVAST *)adRequestResponse;

@end
NS_ASSUME_NONNULL_END
