//
//  RRViewController.h
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 9/7/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RRViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITextView *lblRequest;
@property (weak, nonatomic) IBOutlet UITextView *lblResponse;
- (IBAction)segmentChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong) NSString *requestContent;
@property (strong) NSString *responseContent;

@property (strong) NSString *titleString;

@end
