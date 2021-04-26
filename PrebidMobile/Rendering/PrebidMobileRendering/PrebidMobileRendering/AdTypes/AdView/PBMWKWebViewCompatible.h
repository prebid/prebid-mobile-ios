//
//  PBMWKWebViewCompatible.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

@class WKNavigation;

@protocol PBMWKWebViewCompatible <NSObject>

- (nullable WKNavigation *)loadRequest:(nonnull NSURLRequest *)urlRequest;

@end

