//
//  OXMVideoView+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVideoView.h"


@interface OXMVideoView ()

@property (nonatomic, weak, nullable) OXMVideoCreative *creative;
@property (nonatomic, strong, nonnull) OXMLegalButtonDecorator *legalButtonDecorator;

- (void)updateControls;
- (CGFloat)requiredVideoDuration;

@end
