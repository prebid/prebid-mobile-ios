//
//  MPVASTIndustryIconView.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVASTIndustryIcon.h"
#import "MPVASTResourceView.h"
#import "MPViewabilityObstruction.h"

NS_ASSUME_NONNULL_BEGIN

@class MPVASTIndustryIconView;

@protocol MPVASTIndustryIconViewDelegate <NSObject>

- (void)industryIconView:(MPVASTIndustryIconView *)iconView
         didTriggerEvent:(MPVASTResourceViewEvent)event;

- (void)industryIconView:(MPVASTIndustryIconView *)iconView
didTriggerOverridingClickThrough:(NSURL *)url;

@end

/**
 Implementation note from VAST 3.0 specification:
    Since a vendor often serves icons and may charge advertising parties for each icon served, the
    video player should not pre-fetch the icon resource until the resource can be displayed.
    Pre-fetching the icon resource may cause the icon provider to falsely record an icon view when
    the icon may not have been displayed.
 */
@interface MPVASTIndustryIconView : MPVASTResourceView

@property (nonatomic, readonly) MPVASTIndustryIcon *icon;
@property (nonatomic, weak) id<MPVASTIndustryIconViewDelegate> iconViewDelegate;

- (void)loadIcon:(MPVASTIndustryIcon *)icon;

@end

#pragma mark - MPViewabilityObstruction

@interface MPVASTIndustryIconView (MPViewabilityObstruction) <MPViewabilityObstruction>
/**
 The type of obstruction that this view identifies as.
 */
@property (nonatomic, readonly) MPViewabilityObstructionType viewabilityObstructionType;

/**
 A human-readable name that succinctly describes this obstruction. For convenience, use only the
 predefined constants in `MPViewabilityObstructionName`.
 */
@property (nonatomic, copy, readonly) MPViewabilityObstructionName viewabilityObstructionName;
@end

NS_ASSUME_NONNULL_END
