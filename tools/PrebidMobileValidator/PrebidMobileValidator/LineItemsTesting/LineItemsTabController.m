//
//  LineItemsTabController.m
//  PrebidMobileValidator
//
//  Created by Punnaghai Puviarasu on 4/5/18.
//  Copyright © 2018 AppNexus. All rights reserved.
//

#import "LineItemsTabController.h"
#import "SettingsViewController.h"
#import "LineItemAdsViewController.h"
#import "LogsViewController.h"
#import <MessageUI/MessageUI.h>

NSString *__nonnull const kTitleText = @"AdServer Setup Validator";

@interface LineItemsTabController () <MFMailComposeViewControllerDelegate>


@end

@implementation LineItemsTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = kTitleText;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ScreenGrab" style:UIBarButtonItemStylePlain target:self action:@selector(captureScreen)];
    
    // Do any additional setup after loading the view.
    //SettingsViewController *lineItemsController = [[LineItemsViewController alloc] init];
    
    //UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"GearIcon"] tag:0];
    
    //lineItemsController.tabBarItem = item1;
    
    LineItemAdsViewController *lineItemsAdController = [[LineItemAdsViewController alloc] init];
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"Ads" image:[UIImage imageNamed:@"PhotoIcon"] tag:0];
    
    lineItemsAdController.tabBarItem = item1;
    
    LogsViewController *logsViewController = [[LogsViewController alloc] init];
    
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"Logs" image:[UIImage imageNamed:@"InfoIcon"] tag:1];
    
    logsViewController.tabBarItem = item2;
    
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    //[tabViewControllers addObject:lineItemsController];
    [tabViewControllers addObject:lineItemsAdController];
    [tabViewControllers addObject:logsViewController];
    
    [self setViewControllers: tabViewControllers];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(img, nil, nil,nil);
    [self sendEmail];
    //return img;
}

- (void)sendEmail {
    // Email Subject
    NSString *emailTitle = @"Test Email";
    // Email Content
    NSString *messageBody = @"Test Subject!";
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
