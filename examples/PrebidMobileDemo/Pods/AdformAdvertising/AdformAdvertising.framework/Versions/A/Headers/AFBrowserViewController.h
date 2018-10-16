//
//  AFBrowserViewController.h
//  AdformSDK
//
//  Created by Vladas on 07/07/14.
//  Copyright (c) 2014 adform. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Internal browser used for MRAID open function.
 It opens an add from URL in a new modal viewController with web browser.
 */
@interface AFBrowserViewController : UIViewController

@property (nonatomic, strong, readonly) UIToolbar *toolBar;

@property (nonatomic, strong, readonly) UIProgressView *progressView;

@property (nonatomic, strong, readonly) UIBarButtonItem *backItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *forwardItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *reloadItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *openItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *closeItem;

@end
