//
//  PBMWKScriptMessageHandlerLeakAvoider.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>


// This class is needed to fix memory leak in WKUserContentController.
// Without it the instances of PBMWebView are never destroyed.
// The description of the issue and soulution could be found here:
// https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak

NS_ASSUME_NONNULL_BEGIN
@interface PBMWKScriptMessageHandlerLeakAvoider : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;

@end
NS_ASSUME_NONNULL_END
