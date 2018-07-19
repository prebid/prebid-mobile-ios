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

@end

@implementation IDInputViewController

//- (instancetype)initWithTitle: (NSString *) title andCompletionBlock: (void (^) (NSString *)) completionBlock
//{
//    self = [super init];
//    if (self) {
//        self.title = title;
//        self.completionBlock = completionBlock;
//    }
//    return self;
//}

-(void)viewDidLoad
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    doneButton.target = self;
    doneButton.action = @selector(doneAction:);
    doneButton.title = @"Done";
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
    
    [self.imgScanQRCode setUserInteractionEnabled:YES];
//    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(btnScanQRCode:)];
//
//    tapGesture1.numberOfTapsRequired = 1;
    
    //[tapGesture1 setDelegate:self];
    
    //[self.imgScanQRCode addGestureRecognizer:tapGesture1];

    
//    _idInputTextField = [[UITextField alloc]  initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
//    _idInputTextField.backgroundColor = [UIColor whiteColor];
//    _idInputTextField.textColor = [UIColor blackColor];
//    _scanButtonArea = [[UIView alloc] initWithFrame: CGRectMake(0, 150, self.view.frame.size.width, 50)];
//    _scanButtonArea.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1.0];
//    UIImage *scanImage = [UIImage imageNamed:@"QRIcon.png"];
//    UIImageView *scanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
//    scanImageView.image = scanImage;
//    
//    [_scanButtonArea addSubview:scanImageView];
//    _scanButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 200, 50)];
//    [_scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_scanButton setTitle:@"Scan a QR code" forState:UIControlStateNormal];
//    [_scanButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [_scanButtonArea addSubview:_scanButton];
//    [self.view addSubview:_idInputTextField];
//    [self.view addSubview:_scanButtonArea];
}

//-(void)scanAction: (id) sender
- (IBAction)btnScanQRCode:(id)sender
{
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    __weak typeof(QRCodeReaderViewController)  *vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
    [vc setCompletionWithBlock:^(NSString * _Nullable resultAsString) {
        
        typeof(QRCodeReaderViewController) *svc = vc;
        self.idInputText.text = resultAsString;
        [svc dismissViewControllerAnimated:YES completion:nil];
    }];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}


-(void)doneAction: (id) sender
{
   //get the input id from text field, validate it, set the delegate and dismiss the view
    [self.delegate sendSelectedId:self.idInputText.text forID:self.title];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
