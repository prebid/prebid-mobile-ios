//
//  MPImageLoader.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MPImageLoader;

@protocol MPImageLoaderDelegate <NSObject>

- (BOOL)nativeAdViewInViewHierarchy;

@optional

- (void)imageLoader:(MPImageLoader *)imageLoader didLoadImageIntoImageView:(UIImageView *)imageView;

- (void)imageLoaderDidFailToLoadImageWithError:(NSError *)error;

@end

@interface MPImageLoader : NSObject

@property (nonatomic, weak) id<MPImageLoaderDelegate> delegate;

- (void)loadImageForURL:(NSURL *)imageURL intoImageView:(UIImageView *)imageView;

@end
