//
//  OXMTransactionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@class OXMTransaction;
@class OXMAbstractCreative;

@protocol OXMTransactionDelegate
- (void)transactionReadyForDisplay:(nonnull OXMTransaction *)transaction;
- (void)transactionFailedToLoad:(nonnull OXMTransaction *)transaction error:(nonnull NSError *)error;
@end
