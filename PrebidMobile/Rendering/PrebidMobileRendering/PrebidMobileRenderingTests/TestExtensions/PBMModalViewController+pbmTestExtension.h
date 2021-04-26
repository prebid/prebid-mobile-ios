//
//  OXMModalViewController+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMModalViewController.h"
#import "PBMCloseButtonDecorator.h"

@interface PBMModalViewController ()

@property (nonatomic, strong) PBMCloseButtonDecorator *closeButtonDecorator;
@property (nonatomic, strong) PBMVoidBlock showCloseButtonBlock;
@property (nonatomic, strong) NSDate *startCloseDelay;
@property (nonatomic, assign) BOOL preferAppStatusBarHidden;

- (void)configureSubView;
- (void)closeButtonTapped;

- (void)setupCloseButtonDelay;
- (void)onCloseDelayInterrupted;

@end
