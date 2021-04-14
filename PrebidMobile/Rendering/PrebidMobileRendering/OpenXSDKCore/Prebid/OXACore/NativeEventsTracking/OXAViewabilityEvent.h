//
//  OXAViewabilityEvent.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "OXMVoidBlock.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^OXAExposureSatisfactionCheck)(float exposureFactor);
typedef BOOL (^OXADurationSatisfactionCheck)(NSTimeInterval exposureDuration);

@interface OXAViewabilityEvent : NSObject

@property (nonatomic, copy, readonly) OXAExposureSatisfactionCheck exposureSatisfactionCheck;
@property (nonatomic, copy, readonly) OXADurationSatisfactionCheck durationSatisfactionCheck;
@property (nonatomic, copy, readonly) OXMVoidBlock onEventDetected;

- (instancetype)initWithExposureSatisfactionCheck:(OXAExposureSatisfactionCheck)exposureSatisfactionCheck
                        durationSatisfactionCheck:(OXADurationSatisfactionCheck)durationSatisfactionCheck
                                  onEventDetected:(OXMVoidBlock)onEventDetected;

@end

NS_ASSUME_NONNULL_END
