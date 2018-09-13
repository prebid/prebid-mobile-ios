//
//  RRViewController.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 9/7/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import "RRViewController.h"

@interface RRViewController ()

@end

@implementation RRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Bid Request/Response";
    
    [self.segmentControl setSelectedSegmentIndex:0];
    
    self.lblRequest.hidden = FALSE;
    self.lblResponse.hidden = TRUE;
    
    self.lblRequest.editable = FALSE;
    self.lblResponse.editable = FALSE;
    
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.lblTitle.text = self.titleString;
    
    if(self.requestContent != nil){
        //self.lblRequest.text = self.requestContent;
        self.lblRequest.text = [self prettyJson:self.requestContent];
        [self.lblRequest sizeToFit];
    }
    
    if(self.responseContent != nil){
        //self.lblResponse.text = self.responseContent;
        self.lblResponse.text = [self prettyJson:self.responseContent];
    }
    
}

-(void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)segmentChanged:(id)sender {
    NSInteger selectedIndex = [self.segmentControl selectedSegmentIndex];
    if(selectedIndex == 0){
        self.lblRequest.hidden = FALSE;
        self.lblResponse.hidden = TRUE;
    } else {
        self.lblRequest.hidden = TRUE;
        self.lblResponse.hidden = FALSE;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
