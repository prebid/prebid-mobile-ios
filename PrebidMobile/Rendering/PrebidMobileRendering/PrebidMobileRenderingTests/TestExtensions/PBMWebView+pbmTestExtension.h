//
//  OXMWebView+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMWebView.h"
#import "PBMTransaction.h"

@protocol PBMNSThreadProtocol;

@interface PBMWebView ()

@property (nonatomic, assign, readwrite) PBMWebViewState state;

- (void)loadHTML:(nonnull NSString *)html
         baseURL:(nullable NSURL *)baseURL
         injectMraidJs:(BOOL)injectMraidJs
   currentThread:(nonnull id<PBMNSThreadProtocol>)currentThread;

- (void)expand:(nonnull NSURL *)url
 currentThread:(nonnull id<PBMNSThreadProtocol>)currentThread;

@end
