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
#import "PBVPrebidServerConfigViewController.h"
#import "DemandValidator.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface PBVPrebidServerConfigViewController() <MFMailComposeViewControllerDelegate, UITextViewDelegate>
@property DemandValidator *validator;
@property UIViewController *first;
@property UIViewController *second;
@property UITextView *requestText;
@property UITextView *responseText;
@end

@implementation PBVPrebidServerConfigViewController
- (instancetype)initWithValidator:(DemandValidator *) validator
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
        NSDictionary *results = [validator.testResults copy];
        int successfullTests = [[results objectForKey:@"successfullTests"] intValue];
        NSMutableString *toBeDisplayed = [[NSMutableString alloc] init];
        [toBeDisplayed appendString:@"Hi, the app just ran the demand validation 100 times.\n"];
        [toBeDisplayed appendString:[NSString stringWithFormat:@"%d of tests had responded with at least one bid\n", successfullTests]];
        NSDictionary *bidderPrices = [results objectForKey:@"bidderPrices"];
        int numOfBidders = 0;
        int totalBids = 0;
        double totalBidPrices = 0;
        NSMutableDictionary *bidderAveragePrice = [[NSMutableDictionary alloc] init];
        for (NSString *bidderName in [bidderPrices allKeys]) {
            numOfBidders ++;
            NSArray *prices = [bidderPrices objectForKey:bidderName];
            double sumOfPrices = 0;
            for (NSNumber *price in prices) {
                sumOfPrices += [price doubleValue];
                totalBids++;
            }
            [bidderAveragePrice setObject:[NSNumber numberWithDouble:(sumOfPrices/prices.count)] forKey:bidderName];
            totalBidPrices +=sumOfPrices;
        }
        [toBeDisplayed appendString:[NSString stringWithFormat:@"%d bidders bid: \n", numOfBidders] ];
        for (NSString *bidderName in [bidderPrices allKeys]) {
            NSArray *prices = [bidderPrices objectForKey:bidderName];
            [toBeDisplayed appendString: [NSString stringWithFormat:@"  - %@, sends back %lu bids in total.\n", bidderName, prices.count]];
        }
        [toBeDisplayed appendString:[NSString stringWithFormat:@"Total average bid price is $%f.\n", (totalBidPrices/totalBids)]];
        for (NSString *bidderName in [bidderPrices allKeys]) {
            [toBeDisplayed appendString: [NSString stringWithFormat:@"  - %@ bids $%@ in average.\n", bidderName, [bidderAveragePrice objectForKey:bidderName] ]];
        }
        [toBeDisplayed appendString:@"A sample request is as following: \n"];
        [toBeDisplayed appendString: [self prettyJson:[results objectForKey:@"request"]]];
        [toBeDisplayed appendString:@"\nA sample response is as following: \n"];
        [toBeDisplayed appendString: [self prettyJson:[results objectForKey:@"response"]]];
        _requestText.text = [toBeDisplayed copy];
        _requestText.delegate = self;
        _requestText.editable = NO;
        [_first.view addSubview:_requestText];
        NSArray * controllers = [NSArray arrayWithObjects:_first, nil];
        self.viewControllers = controllers;
        
    }
    return self;
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
        [body appendString:_requestText.text];
        [mailViewController setMessageBody:body isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        UIAlertController *alert = [[UIAlertController alloc] init];
        alert.title = @"Uable to send email";
        alert.message = @"Please set up an email account on your device.";
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:alertAction];
        [self presentViewController: alert animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end


