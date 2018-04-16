//
//  PBVPrebidServerConfigViewController.m
//  PrebidMobileValidator
//
//  Created by Wei Zhang on 4/12/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBVPrebidServerConfigViewController.h"
#import "PBVPBSRequestResponseValidator.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface PBVPrebidServerConfigViewController() <MFMailComposeViewControllerDelegate, UITextViewDelegate>
@property PBVPBSRequestResponseValidator *validator;
@property UIViewController *first;
@property UIViewController *second;
@property UITextView *requestText;
@property UITextView *responseText;
@end

@implementation PBVPrebidServerConfigViewController
- (instancetype)initWithValidator:(PBVPBSRequestResponseValidator *) validator
{
    self = [super init];
    if (self) {
        _validator = validator;
        [self setupEmailButton];
        // set up first tab
        _first = [[UIViewController alloc]init];
        _first.title = @"Request";
        _first.view.backgroundColor = [UIColor whiteColor];
        _requestText = [[UITextView alloc] initWithFrame:self.view.frame];
        _requestText.textColor = [UIColor blackColor];
        _requestText.text = [self prettyJson:validator.request];
        _requestText.delegate = self;
        [_first.view addSubview:_requestText];
        // set up second tab
        _second = [[UIViewController alloc]init];
        _second.title = @"Responsse";
        _second.view.backgroundColor = [UIColor whiteColor];
        _responseText = [[UITextView alloc] initWithFrame:self.view.frame];
        _responseText.text = [self prettyJson: validator.response];
        _responseText.editable = NO;
        [_second.view addSubview:_responseText];
        NSArray * controllers = [NSArray arrayWithObjects:_first, _second, nil];
        self.viewControllers = controllers;
        
    }
    return self;
}
// TextView editing function
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self setupRerunTestButton];
}

-(void) setupRerunTestButton
{
    UIBarButtonItem *rerun = [[UIBarButtonItem alloc]init];
    rerun.style = UIBarButtonItemStylePlain;
    rerun.title = @"Rerun Test";
    rerun.target = self;
    rerun.action = NSSelectorFromString(@"rerunTest:");
    self.navigationItem.rightBarButtonItem = rerun;
}

-(void)rerunTest:(id)sender
{
    // dismiss keyboard
    [_requestText resignFirstResponder];
    // pass new string to validator
    NSString *enteredText = [_requestText text];
      // run the test
    [_validator startTestWithString:enteredText andCompletionHandler:^(Boolean result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // update test result to respoonse
            _responseText.text = [self prettyJson: _validator.response];
            // jump to response tab
            self.selectedIndex = 1;
            // change button back to email me
            [self setupEmailButton];
        });
    }];
}

// Helper function
- (NSString *) prettyJson: (NSString *) jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (jsonObject == nil) {
        return jsonString;
    } else {
        NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
        NSString *prettyPrintedJson = [NSString stringWithUTF8String:[prettyJsonData bytes]];
        return prettyPrintedJson;
    }
}

// Email function
-(void) setupEmailButton
{
    UIBarButtonItem *emailMe =        [[UIBarButtonItem alloc]init];
    emailMe.style = UIBarButtonItemStylePlain;
    emailMe.title = @"Email";
    emailMe.target = self;
    emailMe.action = NSSelectorFromString(@"emailContent:");
    self.navigationItem.rightBarButtonItem = emailMe;
}

-(void) emailContent:(id)sender
{
    NSLog(@"Trying to send request and response data in validator");
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Request and response to/from Prebid Server"];
        NSMutableString *body = [[NSMutableString alloc]initWithString:@""];
        [body appendString: @"Hi, \n\n"];
        [body appendString: @"Please find the request to prebid server below: \n"];
        [body appendString: [self prettyJson: _validator.request]];
        [body appendString: @"\n\nPlease find the response from prebid server below: \n"];
        [body appendString: [self prettyJson: _validator.response]];
        [mailViewController setMessageBody:body isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to send email" message:@"Please set up an email account on your device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end


