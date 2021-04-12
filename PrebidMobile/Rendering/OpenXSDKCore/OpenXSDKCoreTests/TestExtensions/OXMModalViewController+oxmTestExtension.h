//
//  OXMModalViewController+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMModalViewController.h"
#import "OXMCloseButtonDecorator.h"

@interface OXMModalViewController ()

@property (nonatomic, strong) OXMCloseButtonDecorator *closeButtonDecorator;
@property (nonatomic, strong) OXMVoidBlock showCloseButtonBlock;
@property (nonatomic, strong) NSDate *startCloseDelay;
@property (nonatomic, assign) BOOL preferAppStatusBarHidden;

- (void)configureSubView;
- (void)closeButtonTapped;

- (void)setupCloseButtonDelay;
- (void)onCloseDelayInterrupted;

@end
