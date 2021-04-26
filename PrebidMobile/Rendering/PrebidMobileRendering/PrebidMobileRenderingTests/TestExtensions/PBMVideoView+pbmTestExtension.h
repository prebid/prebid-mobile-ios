//
//  OXMVideoView+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVideoView.h"


@interface PBMVideoView ()

@property (nonatomic, weak, nullable) PBMVideoCreative *creative;
@property (nonatomic, strong, nonnull) PBMLegalButtonDecorator *legalButtonDecorator;

- (void)updateControls;
- (CGFloat)requiredVideoDuration;

@end
