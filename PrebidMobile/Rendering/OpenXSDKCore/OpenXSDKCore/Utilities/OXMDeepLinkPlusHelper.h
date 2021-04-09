//
//  OXMDeepLinkPlusHelper.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface OXMDeepLinkPlusHelper : NSObject

+ (BOOL)isDeepLinkPlusURL:(NSURL *)url;
+ (void)tryHandleDeepLinkPlus:(NSURL *)url completion:(void (^)(BOOL visited, NSURL * _Nullable fallbackURL, NSArray<NSURL *> * _Nullable trackingURLs))completion;
+ (void)visitTrackingURLs:(NSArray<NSURL *> *)trackingURLs;

+ (BOOL)isDeepLinkURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
