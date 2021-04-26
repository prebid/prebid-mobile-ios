//
//  PBMCreativeViewDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@class PBMAbstractCreative;

NS_ASSUME_NONNULL_BEGIN
@protocol PBMCreativeViewDelegate <NSObject>
- (void)creativeDidComplete:(PBMAbstractCreative *)creative;
- (void)creativeDidDisplay:(PBMAbstractCreative *)creative;
- (void)creativeWasClicked:(PBMAbstractCreative *)creative;
- (void)creativeViewWasClicked:(PBMAbstractCreative *)creative;
- (void)creativeClickthroughDidClose:(PBMAbstractCreative *)creative;
- (void)creativeInterstitialDidClose:(PBMAbstractCreative *)creative;
- (void)creativeInterstitialDidLeaveApp:(PBMAbstractCreative *)creative;
- (void)creativeFullScreenDidFinish:(PBMAbstractCreative *)creative;

// MRAID Only
- (void)creativeReadyToReimplant:(PBMAbstractCreative *)creative;
- (void)creativeMraidDidCollapse:(PBMAbstractCreative *)creative;
- (void)creativeMraidDidExpand:(PBMAbstractCreative *)creative;

@optional
// Video specific method
- (void)videoCreativeDidComplete:(PBMAbstractCreative *)creative;
- (void)videoWasMuted:(PBMAbstractCreative *)creative;
- (void)videoWasUnmuted:(PBMAbstractCreative *)creative;
@end
NS_ASSUME_NONNULL_END
