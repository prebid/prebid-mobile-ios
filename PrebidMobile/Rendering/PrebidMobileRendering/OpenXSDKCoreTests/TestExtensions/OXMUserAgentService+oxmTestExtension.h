//
//  OXMUserAgentService+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMUserAgentService.h"

@interface OXMUserAgentService (oxmTestExtension)

@property (nonatomic, copy) NSString *sdkVersion;

- (void)setUserAgent;
- (void)setUserAgentInThread:(id<OXMNSThreadProtocol>)thread;

@end
