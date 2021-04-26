//
//  PBMGAMRewardedEventHandler.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PrebidMobileRendering/PBMRewardedEventHandler.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBMGAMRewardedEventHandler : NSObject <PBMRewardedEventHandler>

@property (nonatomic, copy, readonly) NSString *adUnitID;

- (instancetype)initWithAdUnitID:(NSString *)adUnitID;

@end

NS_ASSUME_NONNULL_END
