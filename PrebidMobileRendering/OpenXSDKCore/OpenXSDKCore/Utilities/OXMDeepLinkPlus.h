//
//  OXMDeepLinkPlus.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OXMDeepLinkPlus : NSObject

@property (nonatomic, strong, nonnull, readonly) NSURL *primaryURL;
@property (nonatomic, strong, nullable, readonly) NSURL *fallbackURL;
@property (nonatomic, strong, nullable, readonly) NSArray<NSURL *> *primaryTrackingURLs;
@property (nonatomic, strong, nullable, readonly) NSArray<NSURL *> *fallbackTrackingURLs;

- (instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)deepLinkPlusWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
