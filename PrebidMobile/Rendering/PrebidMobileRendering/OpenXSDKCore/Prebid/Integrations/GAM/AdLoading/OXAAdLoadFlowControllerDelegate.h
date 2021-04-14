//
//  OXAAdLoadFlowControllerDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXAAdLoadFlowController;
@class OXAAdUnitConfig;

NS_ASSUME_NONNULL_BEGIN

@protocol OXAAdLoadFlowControllerDelegate<NSObject>

@property (nonatomic, strong, nonnull, readonly) OXAAdUnitConfig *adUnitConfig;

// Loading callbacks
- (void)adLoadFlowController:(OXAAdLoadFlowController *)adLoadFlowController failedWithError:(nullable NSError *)error;

// Refresh controls hooks
- (void)adLoadFlowControllerWillSendBidRequest:(OXAAdLoadFlowController *)adLoadFlowController;
- (void)adLoadFlowControllerWillRequestPrimaryAd:(OXAAdLoadFlowController *)adLoadFlowController;

// Hook to pause the flow between 'loading' states
- (BOOL)adLoadFlowControllerShouldContinue:(OXAAdLoadFlowController *)adLoadFlowController;

@end

NS_ASSUME_NONNULL_END
