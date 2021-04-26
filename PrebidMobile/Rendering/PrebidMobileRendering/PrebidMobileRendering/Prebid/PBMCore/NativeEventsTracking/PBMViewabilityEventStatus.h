//
//  PBMViewabilityEventStatus.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMViewabilityEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMViewabilityEventStatus : NSObject

@property (nonatomic, strong, readonly) PBMViewabilityEvent *viewabilityEvent;

@property (nonatomic, assign) BOOL detected;
@property (nonatomic, assign) NSTimeInterval satisfactionProgress; // seconds
@property (nonatomic, assign) BOOL isProgressing;

- (instancetype)initWithViewabilityEvent:(PBMViewabilityEvent *)viewabilityEvent;

@end

NS_ASSUME_NONNULL_END
