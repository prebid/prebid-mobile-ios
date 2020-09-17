/*
 *    Copyright 2018 Prebid.org, Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "IDInputViewController.h"
#import "QRCodeReaderViewController.h"
#import "PBVSharedConstants.h"

@interface IDInputViewController () <QRCodeReaderDelegate>

@end

@implementation IDInputViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
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
    if([self.title isEqualToString:kPBHostText]){
        NSURL *url = [NSURL URLWithString:self.idInputText.text];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        bool valid = [NSURLConnection canHandleRequest:req];
        if (valid){
            //get the input id from text field, validate it, set the delegate and dismiss the view
            [self.delegate sendSelectedId:self.idInputText.text forID:self.title];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Host" message:@"Provided host URL is invalid." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* noButton = [UIAlertAction
            actionWithTitle:@"Ok"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {
                //Handle no, thanks button
                return;
            }];
            [alert addAction:noButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    } else {
        //get the input id from text field, validate it, set the delegate and dismiss the view
           [self.delegate sendSelectedId:self.idInputText.text forID:self.title];
           
           [self.navigationController popViewControllerAnimated:YES];
    }
    
  
}

@end
