//
//  PBMAbstractCreative+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "PBMAbstractCreative.h"
#import "PBMVoidBlock.h"

@class PrebidRenderingConfig;

NS_ASSUME_NONNULL_BEGIN

@interface PBMAbstractCreative (Protected)

//Clickthrough handling
- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration;

- (void)handleClickthrough:(NSURL*)url
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(PBMVoidBlock)onClickthroughExitBlock;

- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(PrebidRenderingConfig *)sdkConfiguration
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(PBMVoidBlock)onClickthroughExitBlock;

- (void)onWillTrackImpression;

//Virtual methods (non-abstract)
- (void)onAdDisplayed;

@end

NS_ASSUME_NONNULL_END
