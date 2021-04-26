//
//  PBMInterstitialDisplayProperties.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMInterstitialDisplayProperties.h"
#import "PBMFunctions+Private.h"

@interface PBMInterstitialDisplayProperties()
@property (nonatomic, strong) UIImage *closeButtonImage;
@end

@implementation PBMInterstitialDisplayProperties

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.closeDelay = 0;
        self.closeDelayLeft = 0;
        self.contentFrame = CGRectInfinite;
        self.contentViewColor = [UIColor clearColor];
        self.closeButtonImage = [UIImage imageNamed:@"PBM_closeButton" inBundle:[PBMFunctions bundleForSDK] compatibleWithTraitCollection:nil];
        self.interstitialLayout = PBMInterstitialLayoutUndefined;
    }
    return self;
}

#pragma mark - closeButtonImage

- (void)setCloseButtonImage:(UIImage *)newValue {
    //Prevent setting nils
    if (newValue) {
        _closeButtonImage = newValue;
        //Explicitly set the accessibility identifier every time the close button image is set.
        //This prevents the file name from informing the identifier.
        self.closeButtonImage.accessibilityIdentifier = PBMAccesibility.CloseButtonIdentifier;
        self.closeButtonImage.accessibilityLabel = PBMAccesibility.CloseButtonLabel;
    }
}

- (UIImage *)getCloseButtonImage {
    return self.closeButtonImage;
}

- (void)setButtonImageHidden {
    self.closeButtonImage = [UIImage new];
}

- (BOOL)isRotationEnabled {
    return (self.interstitialLayout == PBMInterstitialLayoutAspectRatio);
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone {
    PBMInterstitialDisplayProperties *ret = [[PBMInterstitialDisplayProperties alloc] init];
    ret.closeDelay = self.closeDelay;
    ret.closeButtonImage = self.closeButtonImage;
    ret.closeDelayLeft = self.closeDelayLeft;
    ret.contentFrame = self.contentFrame;
    ret.contentViewColor = self.contentViewColor;
    ret.interstitialLayout = self.interstitialLayout;
    return ret;
}

@end
