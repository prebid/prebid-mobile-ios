//
//  OXANativeAdMediaHooks.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAViewControllerProvider.h"
#import "OXACreativeClickHandlerBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdMediaHooks : NSObject

/// Implicit implementor of [OXMAdViewManagerDelegate viewControllerForModalPresentation]
/// Required by OXMAdViewManager to successfully embed cretive views into containers.
/// Might be useful in case of MRAID in End Card.
@property (nonatomic, copy, readonly) OXAViewControllerProvider viewControllerProvider;

/// Click handler's behavior depends not solely on specific asset's link, but also on the parent's (native ad's) link object.
/// Thus the appropriate behavior should be calculated and injected from the higher levels.
@property (nonatomic, copy, nullable) OXACreativeClickHandlerBlock clickHandlerOverride;

- (instancetype)initWithViewControllerProvider:(OXAViewControllerProvider)viewControllerProvider
                          clickHandlerOverride:(OXACreativeClickHandlerBlock)clickHandlerOverride NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
