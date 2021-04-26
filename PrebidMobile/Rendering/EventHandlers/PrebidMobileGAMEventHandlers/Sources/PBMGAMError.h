//
//  PBMGAMError.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMGAMError : NSObject

@property (nonatomic, class, readonly) NSError *gamClassesNotFound;
@property (nonatomic, class, readonly) NSError *noLocalCacheID;
@property (nonatomic, class, readonly) NSError *invalidLocalCacheID;
@property (nonatomic, class, readonly) NSError *invalidNativeAd;

+ (void)logError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
