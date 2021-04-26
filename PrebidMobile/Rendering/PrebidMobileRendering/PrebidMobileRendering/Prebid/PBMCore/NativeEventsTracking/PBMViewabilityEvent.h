//
//  PBMViewabilityEvent.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^PBMExposureSatisfactionCheck)(float exposureFactor);
typedef BOOL (^PBMDurationSatisfactionCheck)(NSTimeInterval exposureDuration);

@interface PBMViewabilityEvent : NSObject

@property (nonatomic, copy, readonly) PBMExposureSatisfactionCheck exposureSatisfactionCheck;
@property (nonatomic, copy, readonly) PBMDurationSatisfactionCheck durationSatisfactionCheck;
@property (nonatomic, copy, readonly) PBMVoidBlock onEventDetected;

- (instancetype)initWithExposureSatisfactionCheck:(PBMExposureSatisfactionCheck)exposureSatisfactionCheck
                        durationSatisfactionCheck:(PBMDurationSatisfactionCheck)durationSatisfactionCheck
                                  onEventDetected:(PBMVoidBlock)onEventDetected;

@end

NS_ASSUME_NONNULL_END
