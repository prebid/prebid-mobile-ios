//
//  OXMCreativeViewDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@class OXMAbstractCreative;

NS_ASSUME_NONNULL_BEGIN
@protocol OXMCreativeViewDelegate <NSObject>
- (void)creativeDidComplete:(OXMAbstractCreative *)creative;
- (void)creativeDidDisplay:(OXMAbstractCreative *)creative;
- (void)creativeWasClicked:(OXMAbstractCreative *)creative;
- (void)creativeViewWasClicked:(OXMAbstractCreative *)creative;
- (void)creativeClickthroughDidClose:(OXMAbstractCreative *)creative;
- (void)creativeInterstitialDidClose:(OXMAbstractCreative *)creative;
- (void)creativeInterstitialDidLeaveApp:(OXMAbstractCreative *)creative;
- (void)creativeFullScreenDidFinish:(OXMAbstractCreative *)creative;

// MRAID Only
- (void)creativeReadyToReimplant:(OXMAbstractCreative *)creative;
- (void)creativeMraidDidCollapse:(OXMAbstractCreative *)creative;
- (void)creativeMraidDidExpand:(OXMAbstractCreative *)creative;

@optional
// Video specific method
- (void)videoCreativeDidComplete:(OXMAbstractCreative *)creative;
- (void)videoWasMuted:(OXMAbstractCreative *)creative;
- (void)videoWasUnmuted:(OXMAbstractCreative *)creative;
@end
NS_ASSUME_NONNULL_END
