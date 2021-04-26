//
//  PBMMoPubError.h
//  OpenXApolloMoPubAdapters
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrebidMoPubError : NSObject

@property (nonatomic, class, readonly) NSError *noLocalCacheID;
@property (nonatomic, class, readonly) NSError *invalidLocalCacheID;
@property (nonatomic, class, readonly) NSError *invalidNativeAd;

@end

NS_ASSUME_NONNULL_END
