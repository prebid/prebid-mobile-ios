//
//  LogsViewController.m
//  PrebidMobileValidator
//
//  Created by Punnaghai Puviarasu on 4/5/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "LineItemLogViewController.h"
#import "PBVSharedConstants.h"
#import "UILabel+DynamicSize.h"
#import <MessageUI/MessageUI.h>

@interface LineItemLogViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic) UITextView *requestLabel;
@property (nonatomic) UITextView *responseLabel;

@end

@implementation LineItemLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStylePlain target:self action:@selector(sendEmail)];
    
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"Punnaghai request %@", [[PBVSharedConstants sharedInstance] requestString]);
    
    UILabel *requestText = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width-50, 20)];
    [requestText setText: @"Request"];
    [requestText setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview: requestText];
    
    self.requestLabel = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, self.view.frame.size.width-50, 20)];
    [self.requestLabel setText: [[PBVSharedConstants sharedInstance] requestString]];
    [self.requestLabel sizeToFit];
    [self.requestLabel setEditable:FALSE];
    [self.view addSubview: self.requestLabel];
    
    
    UILabel *responseText = [[UILabel alloc] initWithFrame:CGRectMake(0, self.requestLabel.frame.size.height+self.requestLabel.frame.origin.y+20 , self.view.frame.size.width-50, 20)];
    [responseText setText: @"Response"];
    [responseText setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview: responseText];
    
    self.responseLabel = [[UITextView alloc] initWithFrame:CGRectMake(20, responseText.frame.origin.y+20 , self.view.frame.size.width-50, 20)];
    [self.responseLabel setText:[[PBVSharedConstants sharedInstance] responseString]];
    [self.responseLabel sizeToFit];
    [self.responseLabel setEditable:FALSE];
    [self.view addSubview: self.responseLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendEmail {
    // Email Subject
    NSString *emailTitle = @"AdServer Logs";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"Request: \n %@ \n Response: \n %@", [[PBVSharedConstants sharedInstance] requestString], [[PBVSharedConstants sharedInstance] responseString] ];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@test.com"];
    
    if([MFMessageComposeViewController canSendText]){
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
