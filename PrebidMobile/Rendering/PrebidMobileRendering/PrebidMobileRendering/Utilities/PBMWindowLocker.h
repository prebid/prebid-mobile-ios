//
//  PBMWindowLocker.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIWindow;
@class PBMOpenMeasurementSession;

NS_ASSUME_NONNULL_BEGIN

@interface PBMWindowLocker : NSObject

@property (nonatomic, assign, readonly, getter=isLocked) BOOL locked;

- (instancetype)initWithWindow:(UIWindow*)window measurementSession:(PBMOpenMeasurementSession *)measurementSession;

- (void)lock;
- (void)unlock;

@end

NS_ASSUME_NONNULL_END
