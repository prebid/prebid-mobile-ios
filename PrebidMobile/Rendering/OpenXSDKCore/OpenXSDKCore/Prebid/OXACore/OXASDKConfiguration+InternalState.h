//
//  OXASDKConfiguration+InternalState.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenXApolloSDK/OXASDKConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXASDKConfiguration ()

/// [NSTimeInterval]
/// In seconds.
@property (nonatomic, strong, nullable) NSNumber *bidRequestTimeoutDynamic;
@property (nonatomic, readonly) NSLock *bidRequestTimeoutLock;

@property (nonatomic, copy) NSString *serverURL;

@property (nonatomic, class, readonly) NSString *prodServerURL;

@end

NS_ASSUME_NONNULL_END


