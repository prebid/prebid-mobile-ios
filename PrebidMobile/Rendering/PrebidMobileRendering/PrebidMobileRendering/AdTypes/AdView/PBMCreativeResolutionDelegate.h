//
//  PBMCreativeResolutionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMAbstractCreative;

NS_ASSUME_NONNULL_BEGIN
@protocol PBMCreativeResolutionDelegate

- (void)creativeReady:(PBMAbstractCreative *)creative;
- (void)creativeFailed:(NSError *)error;

@end
NS_ASSUME_NONNULL_END
