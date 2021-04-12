//
//  OXMVideoCreative+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVideoCreative.h"


@interface OXMVideoCreative ()

@property (nonatomic, strong) OXMVideoView* videoView;

- (NSTimeInterval)calculateCloseDelayForPubCloseDelay:(NSTimeInterval)pubCloseDelay;

@end
