//
//  OXMAdLoadManagerDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@protocol OXMAdLoadManagerProtocol;
@class OXMTransaction;

NS_ASSUME_NONNULL_BEGIN
@protocol OXMAdLoadManagerDelegate

- (void)loadManager:(id<OXMAdLoadManagerProtocol>)loadManager didLoadTransaction:(OXMTransaction *)transaction;

- (void)loadManager:(id<OXMAdLoadManagerProtocol>)loadManager failedToLoadTransaction:(nullable OXMTransaction *)transaction error:(NSError *)error;

@end
NS_ASSUME_NONNULL_END

