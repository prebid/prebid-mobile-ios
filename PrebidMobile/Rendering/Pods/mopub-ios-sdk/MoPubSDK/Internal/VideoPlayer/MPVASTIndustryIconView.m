//
//  MPVASTIndustryIconView.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPLogging.h"
#import "MPVASTIndustryIconView.h"

@interface MPVASTIndustryIconView ()

@property (nonatomic, strong) MPVASTIndustryIcon *icon;

@end

@interface MPVASTIndustryIconView (MPVASTResourceViewDelegate) <MPVASTResourceViewDelegate>
@end

#pragma mark - MPVASTIndustryIconView

@implementation MPVASTIndustryIconView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.resourceViewDelegate = self;

        // Industry icons support transparency.
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)loadIcon:(MPVASTIndustryIcon *)icon {
    self.icon = icon;
    [self loadResource:icon.resourceToDisplay containerSize:CGSizeMake(icon.width, icon.height)];
}

@end

#pragma mark - MPVASTResourceViewDelegate

@implementation MPVASTIndustryIconView (MPVASTResourceViewDelegate)

- (void)vastResourceView:(MPVASTResourceView *)vastResourceView
         didTriggerEvent:(MPVASTResourceViewEvent)event {
    if (vastResourceView == self) {
        [self.iconViewDelegate industryIconView:self didTriggerEvent:event];
    } else {
        MPLogError(@"Unexpected `MPVASTResourceView` callback for %@", vastResourceView);
    }
}

- (void)vastResourceView:(MPVASTResourceView *)vastResourceView
didTriggerOverridingClickThrough:(NSURL *)url {
    [self.iconViewDelegate industryIconView:self didTriggerOverridingClickThrough:url];
}

@end

#pragma mark - MPViewabilityObstruction

@implementation MPVASTIndustryIconView (MPViewabilityObstruction)

- (MPViewabilityObstructionType)viewabilityObstructionType {
    return MPViewabilityObstructionTypeOther;
}

- (MPViewabilityObstructionName)viewabilityObstructionName {
    return MPViewabilityObstructionNameIndustryIcon;
}

@end
