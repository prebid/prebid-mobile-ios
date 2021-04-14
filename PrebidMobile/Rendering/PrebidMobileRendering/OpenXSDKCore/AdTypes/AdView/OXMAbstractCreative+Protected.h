//
//  OXMAbstractCreative+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import "OXMAbstractCreative.h"
#import "OXMVoidBlock.h"

@class OXASDKConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OXMAbstractCreative (Protected)

//Clickthrough handling
- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration;

- (void)handleClickthrough:(NSURL*)url
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(OXMVoidBlock)onClickthroughExitBlock;

- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(OXMVoidBlock)onClickthroughExitBlock;

- (void)onWillTrackImpression;

//Virtual methods (non-abstract)
- (void)onAdDisplayed;

@end

NS_ASSUME_NONNULL_END
