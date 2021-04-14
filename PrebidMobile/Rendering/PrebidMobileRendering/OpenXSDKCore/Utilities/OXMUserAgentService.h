//
//  OXMUserAgentService.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Service for retrieving OpenX SDK's User-Agent string.
 *
 * The `singleton` class property should be used rather than instantiating directly.
 */
@interface OXMUserAgentService : NSObject

/**
 * Entry point for accessing official SDK User-Agent.
 */
+ (nonnull instancetype)singleton;

/**
 * Returns the `WKWebView`'s User-Agent with the SDK version appened.
 */
- (nonnull NSString *)getFullUserAgent;

@end
