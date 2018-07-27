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
    [self.idInputText becomeFirstResponder];
    
}

//-(void)scanAction: (id) sender
- (IBAction)btnScanQRCode:(id)sender
{
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    __weak typeof(QRCodeReaderViewController)  *vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
        [vc setCompletionWithBlock:^(NSString * _Nullable resultAsString) {
        
        typeof(QRCodeReaderViewController) *svc = vc;
        [self.idInputText setText:resultAsString];
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
