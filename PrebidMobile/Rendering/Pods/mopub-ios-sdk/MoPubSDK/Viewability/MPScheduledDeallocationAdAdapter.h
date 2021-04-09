//
//  MPScheduledDeallocationAdAdapter.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol for rendering adapters that require scheduled deallocation via @c MPViewabilityManager.
 */
@protocol MPScheduledDeallocationAdAdapter <NSObject>

/**
 Ends the Viewability session for this adapter.
 */
- (void)stopViewabilitySession;

@end

NS_ASSUME_NONNULL_END
