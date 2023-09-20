/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMInterstitialDisplayProperties.h"
#import "PBMFunctions+Private.h"

#import "PrebidMobileSwiftHeaders.h"

#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

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
        self.closeButtonImage = PrebidImagesRepository.closeButton.base64DecodedImage;
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
