//
//  MPWebView+Viewability.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <WebKit/WebKit.h>
#import "MPWebView.h"

@interface MPWebView (Viewability)

/**
 Returns the @c WKWebView instance attached to this @c MPWebView.
 Exposed for the purposes of integrating with Viewability.

 @note Please do not alter the hierarchy of this view (i.e., don't ever call it with `addSubview` or
 `removeFromSuperview`). Call those methods on the MPWebView instance instead.
 */
@property (nonatomic, weak, readonly) WKWebView *wkWebView;

@end
