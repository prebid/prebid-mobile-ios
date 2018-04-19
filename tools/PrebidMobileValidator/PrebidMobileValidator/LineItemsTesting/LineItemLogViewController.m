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

@property (nonatomic) UILabel *requestLabel;
@property (nonatomic) UILabel *responseLabel;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation LineItemLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStylePlain target:self action:@selector(sendEmail)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"Punnaghai request %@", [[PBVSharedConstants sharedInstance] requestString]);
    
    UILabel *requestText = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width-50, 20)];
    [requestText setText: @"Request"];
    [requestText setFont:[UIFont boldSystemFontOfSize:16]];
    [self.scrollView addSubview: requestText];
    
    self.requestLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, self.view.frame.size.width-50, 20)];
    self.requestLabel.numberOfLines = 0;
    self.requestLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.requestLabel setText: [[PBVSharedConstants sharedInstance] requestString]];
    [self.requestLabel sizeToFit];
    [self.scrollView addSubview: self.requestLabel];
    
    
    UILabel *responseText = [[UILabel alloc] initWithFrame:CGRectMake(0, self.requestLabel.frame.size.height+self.requestLabel.frame.origin.y+20 , self.view.frame.size.width-50, 20)];
    [responseText setText: @"Response"];
    [responseText setFont:[UIFont boldSystemFontOfSize:16]];
    [self.scrollView addSubview: responseText];
    
    self.responseLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, responseText.frame.origin.y+20 , self.view.frame.size.width-50, 20)];
    self.responseLabel.numberOfLines = 0;
    self.responseLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.responseLabel setText: [[PBVSharedConstants sharedInstance] responseString]];
    [self.responseLabel sizeToFit];
    [self.scrollView addSubview: self.responseLabel];
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
