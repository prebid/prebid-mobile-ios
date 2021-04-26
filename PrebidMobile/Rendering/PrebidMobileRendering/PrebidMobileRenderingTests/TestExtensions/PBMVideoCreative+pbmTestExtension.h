//
//  OXMVideoCreative+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVideoCreative.h"


@interface PBMVideoCreative ()

@property (nonatomic, strong) PBMVideoView* videoView;

- (NSTimeInterval)calculateCloseDelayForPubCloseDelay:(NSTimeInterval)pubCloseDelay;

@end
