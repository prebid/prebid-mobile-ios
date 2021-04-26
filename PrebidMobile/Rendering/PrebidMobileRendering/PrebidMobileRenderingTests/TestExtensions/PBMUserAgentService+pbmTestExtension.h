//
//  OXMUserAgentService+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMUserAgentService.h"

@interface PBMUserAgentService (pbmTestExtension)

@property (nonatomic, copy) NSString *sdkVersion;

- (void)setUserAgent;
- (void)setUserAgentInThread:(id<PBMNSThreadProtocol>)thread;

@end
