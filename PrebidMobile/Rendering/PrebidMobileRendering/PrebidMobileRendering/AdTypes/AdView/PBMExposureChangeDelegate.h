//
//  PBMExposureChangeDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMWebView;
@class PBMViewExposure;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMExposureChangeDelegate <NSObject>

- (void)webView:(PBMWebView *)webView exposureChange:(PBMViewExposure *)viewExposure;
- (BOOL)shouldCheckExposure;

@end
NS_ASSUME_NONNULL_END
