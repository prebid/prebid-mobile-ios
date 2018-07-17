//
//  IDInputViewController.m
//  Dr.Prebid
//
//  Created by Wei Zhang on 7/16/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDInputViewController.h"
#import "QRCodeReaderViewController.h"

@interface IDInputViewController () <QRCodeReaderDelegate>
@property UITextField *idInputTextField;
@property UIView *scanButtonArea;
@property UIImageView *scanImage;
@property UIButton *scanButton;
@property void (^completionBlock) (NSString *);
@end

@implementation IDInputViewController

- (instancetype)initWithTitle: (NSString *) title andCompletionBlock: (void (^) (NSString *)) completionBlock
{
    self = [super init];
    if (self) {
        self.title = title;
        self.completionBlock = completionBlock;
    }
    return self;
}
-(void)viewDidLoad
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    doneButton.target = self;
    doneButton.action = @selector(doneAction:);
    doneButton.title = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
    _idInputTextField = [[UITextField alloc]  initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    _idInputTextField.backgroundColor = [UIColor whiteColor];
    _idInputTextField.textColor = [UIColor blackColor];
    _scanButtonArea = [[UIView alloc] initWithFrame: CGRectMake(0, 150, self.view.frame.size.width, 50)];
    _scanButtonArea.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
    _scanButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 200, 50)];
    [_scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scanButton setTitle:@"Scan a QR code" forState:UIControlStateNormal];
    [_scanButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_scanButtonArea addSubview:_scanButton];
    [self.view addSubview:_idInputTextField];
    [self.view addSubview:_scanButtonArea];
}

-(void)scanAction: (id) sender
{
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    __weak typeof(QRCodeReaderViewController)  *vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
    [vc setCompletionWithBlock:^(NSString * _Nullable resultAsString) {
        
        typeof(QRCodeReaderViewController) *svc = vc;
        self.idInputTextField.text = resultAsString;
        [svc dismissViewControllerAnimated:YES completion:nil];
    }];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}


-(void)doneAction: (id) sender
{
   //get the input id from text field, validate it, call completion block, back to previous screen
    self.completionBlock(self.idInputTextField.text);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
