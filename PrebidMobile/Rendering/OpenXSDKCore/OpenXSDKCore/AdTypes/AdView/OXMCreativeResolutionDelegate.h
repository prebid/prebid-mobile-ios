//
//  OXMCreativeResolutionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMAbstractCreative;

NS_ASSUME_NONNULL_BEGIN
@protocol OXMCreativeResolutionDelegate

- (void)creativeReady:(OXMAbstractCreative *)creative;
- (void)creativeFailed:(NSError *)error;

@end
NS_ASSUME_NONNULL_END
