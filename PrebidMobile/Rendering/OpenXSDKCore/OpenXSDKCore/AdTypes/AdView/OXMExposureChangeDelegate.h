//
//  OXMExposureChangeDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OXMWebView;
@class OXMViewExposure;

NS_ASSUME_NONNULL_BEGIN

@protocol OXMExposureChangeDelegate <NSObject>

- (void)webView:(OXMWebView *)webView exposureChange:(OXMViewExposure *)viewExposure;
- (BOOL)shouldCheckExposure;

@end
NS_ASSUME_NONNULL_END
