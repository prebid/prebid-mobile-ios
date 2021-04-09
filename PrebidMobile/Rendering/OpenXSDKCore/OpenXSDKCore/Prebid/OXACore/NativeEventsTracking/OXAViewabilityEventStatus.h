//
//  OXAViewabilityEventStatus.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAViewabilityEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAViewabilityEventStatus : NSObject

@property (nonatomic, strong, readonly) OXAViewabilityEvent *viewabilityEvent;

@property (nonatomic, assign) BOOL detected;
@property (nonatomic, assign) NSTimeInterval satisfactionProgress; // seconds
@property (nonatomic, assign) BOOL isProgressing;

- (instancetype)initWithViewabilityEvent:(OXAViewabilityEvent *)viewabilityEvent;

@end

NS_ASSUME_NONNULL_END
