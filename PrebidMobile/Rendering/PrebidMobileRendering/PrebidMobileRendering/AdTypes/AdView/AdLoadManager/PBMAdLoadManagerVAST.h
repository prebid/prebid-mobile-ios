//
//  PBMAdLoadManagerVAST.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMAdLoadManagerBase.h"
@class PBMAdRequestResponseVAST;

NS_ASSUME_NONNULL_BEGIN
@interface PBMAdLoadManagerVAST : PBMAdLoadManagerBase

- (void)loadFromString:(NSString *)vastString;
- (void)requestCompletedSuccess:(PBMAdRequestResponseVAST *)adRequestResponse;

@end
NS_ASSUME_NONNULL_END
