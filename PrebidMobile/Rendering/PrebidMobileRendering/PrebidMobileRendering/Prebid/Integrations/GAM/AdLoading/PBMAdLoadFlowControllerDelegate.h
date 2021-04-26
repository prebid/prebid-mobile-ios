//
//  PBMAdLoadFlowControllerDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMAdLoadFlowController;
@class PBMAdUnitConfig;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMAdLoadFlowControllerDelegate<NSObject>

@property (nonatomic, strong, nonnull, readonly) PBMAdUnitConfig *adUnitConfig;

// Loading callbacks
- (void)adLoadFlowController:(PBMAdLoadFlowController *)adLoadFlowController failedWithError:(nullable NSError *)error;

// Refresh controls hooks
- (void)adLoadFlowControllerWillSendBidRequest:(PBMAdLoadFlowController *)adLoadFlowController;
- (void)adLoadFlowControllerWillRequestPrimaryAd:(PBMAdLoadFlowController *)adLoadFlowController;

// Hook to pause the flow between 'loading' states
- (BOOL)adLoadFlowControllerShouldContinue:(PBMAdLoadFlowController *)adLoadFlowController;

@end

NS_ASSUME_NONNULL_END
