//
//  OXMWKWebViewCompatible.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#ifndef OXMWKWebViewCompatible_h
#define OXMWKWebViewCompatible_h

@class WKNavigation;

@protocol OXMWKWebViewCompatible <NSObject>

- (nullable WKNavigation *)loadRequest:(nonnull NSURLRequest *)urlRequest;

@end

#endif /* OXMWKWebViewCompatible_h */
