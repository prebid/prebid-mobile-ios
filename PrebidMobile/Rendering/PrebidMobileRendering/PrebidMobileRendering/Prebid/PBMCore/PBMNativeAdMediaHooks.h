//
//  PBMNativeAdMediaHooks.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMViewControllerProvider.h"
#import "PBMCreativeClickHandlerBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMediaHooks : NSObject

/// Implicit implementor of [PBMAdViewManagerDelegate viewControllerForModalPresentation]
/// Required by PBMAdViewManager to successfully embed cretive views into containers.
/// Might be useful in case of MRAID in End Card.
@property (nonatomic, copy, readonly) PBMViewControllerProvider viewControllerProvider;

/// Click handler's behavior depends not solely on specific asset's link, but also on the parent's (native ad's) link object.
/// Thus the appropriate behavior should be calculated and injected from the higher levels.
@property (nonatomic, copy, nullable) PBMCreativeClickHandlerBlock clickHandlerOverride;

- (instancetype)initWithViewControllerProvider:(PBMViewControllerProvider)viewControllerProvider
                          clickHandlerOverride:(PBMCreativeClickHandlerBlock)clickHandlerOverride NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
