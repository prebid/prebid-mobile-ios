//
//  PBMAdLoadFlowControllerDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdUnitConfig;
@class PBMAdLoadFlowController;

NS_ASSUME_NONNULL_BEGIN

// TODO: try to make me private
@protocol PBMAdLoadFlowControllerDelegate<NSObject>

@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adUnitConfig;

// Loading callbacks
- (void)adLoadFlowController:(PBMAdLoadFlowController *)adLoadFlowController failedWithError:(nullable NSError *)error;

// Refresh controls hooks
- (void)adLoadFlowControllerWillSendBidRequest:(PBMAdLoadFlowController *)adLoadFlowController;
- (void)adLoadFlowControllerWillRequestPrimaryAd:(PBMAdLoadFlowController *)adLoadFlowController;

// Hook to pause the flow between 'loading' states
- (BOOL)adLoadFlowControllerShouldContinue:(PBMAdLoadFlowController *)adLoadFlowController;

@end

NS_ASSUME_NONNULL_END
