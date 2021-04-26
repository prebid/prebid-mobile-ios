//
//  PBMTransactionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@class PBMTransaction;
@class PBMAbstractCreative;

@protocol PBMTransactionDelegate
- (void)transactionReadyForDisplay:(nonnull PBMTransaction *)transaction;
- (void)transactionFailedToLoad:(nonnull PBMTransaction *)transaction error:(nonnull NSError *)error;
@end
