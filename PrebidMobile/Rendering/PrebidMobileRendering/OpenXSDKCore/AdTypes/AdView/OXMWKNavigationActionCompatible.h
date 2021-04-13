//
//  OXMWKNavigationActionCompatible.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#ifndef OXMWKNavigationActionCompatible_h
#define OXMWKNavigationActionCompatible_h

@class NSURLRequest;

@protocol OXMWKNavigationActionCompatible <NSObject>

@property(nonatomic, readonly, copy) NSURLRequest *request;

@end

#endif /* OXMWKNavigationActionCompatible_h */
