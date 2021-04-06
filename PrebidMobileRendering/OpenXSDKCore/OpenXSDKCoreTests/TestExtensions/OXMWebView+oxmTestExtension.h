//
//  OXMWebView+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMWebView.h"
#import "OXMTransaction.h"

@protocol OXMNSThreadProtocol;

@interface OXMWebView ()

@property (nonatomic, assign, readwrite) OXMWebViewState state;

- (void)loadHTML:(nonnull NSString *)html
         baseURL:(nullable NSURL *)baseURL
         injectMraidJs:(BOOL)injectMraidJs
   currentThread:(nonnull id<OXMNSThreadProtocol>)currentThread;

- (void)expand:(nonnull NSURL *)url
 currentThread:(nonnull id<OXMNSThreadProtocol>)currentThread;

@end
