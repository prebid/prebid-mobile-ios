//
//  PBMAdLoadManagerDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@protocol PBMAdLoadManagerProtocol;
@class PBMTransaction;

NS_ASSUME_NONNULL_BEGIN
@protocol PBMAdLoadManagerDelegate

- (void)loadManager:(id<PBMAdLoadManagerProtocol>)loadManager didLoadTransaction:(PBMTransaction *)transaction;

- (void)loadManager:(id<PBMAdLoadManagerProtocol>)loadManager failedToLoadTransaction:(nullable PBMTransaction *)transaction error:(NSError *)error;

@end
NS_ASSUME_NONNULL_END

