//
//  PBMNativeAdEventTracker+FromMarkup.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAdEventTracker.h"
#import "PBMNativeAdMarkupEventTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdEventTracker ()

- (instancetype)initWithNativeAdMarkupEventTracker:(PBMNativeAdMarkupEventTracker *)nativeAdMarkupEventTracker;

@end

NS_ASSUME_NONNULL_END
