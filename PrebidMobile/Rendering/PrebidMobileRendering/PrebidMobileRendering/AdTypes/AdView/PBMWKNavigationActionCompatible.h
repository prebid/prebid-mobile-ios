//
//  PBMWKNavigationActionCompatible.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

@class NSURLRequest;

@protocol PBMWKNavigationActionCompatible <NSObject>

@property(nonatomic, readonly, copy) NSURLRequest *request;

@end

