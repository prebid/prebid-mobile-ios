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

#import "RRViewController.h"
#import "ColorTool.h"

@interface RRViewController ()

@property (nonatomic, strong) NSString *finalRequestString;
@property (nonatomic, strong) NSString *finalResponseString;
@end

@implementation RRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Bid Request/Response";
    
    [self.segmentControl setSelectedSegmentIndex:0];
    self.contentTextView.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    [self performSelectorOnMainThread:@selector(formattedContent) withObject:nil waitUntilDone:YES];
    
}

- (void) formattedContent {
     __weak RRViewController *weakSelf = self;
    
    [self prettyJsonString:self.requestContent andCompletionHandler:^(NSString *formatedString) {
        __strong RRViewController *strongSelf = weakSelf;
        strongSelf.finalRequestString = formatedString;
    }];
    
    [self prettyJsonString:self.responseContent andCompletionHandler:^(NSString *formatedString) {
        __strong RRViewController *strongSelf = weakSelf;
        strongSelf.finalResponseString = formatedString;
    }];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.lblTitle.text = self.titleString;
    [self.contentTextView setFont:[UIFont fontWithName:@"Courier" size:14.0]];
    [self.contentTextView setTextColor:[ColorTool prebidCodeSnippetGrey]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentTextView.text = self.finalRequestString;
        
    });
    
}

-(void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)segmentChanged:(id)sender {
    NSInteger selectedIndex = [self.segmentControl selectedSegmentIndex];
    self.contentTextView.text = @"";
    //[self.contentTextView setEditable:YES];
    if(selectedIndex == 0){
        if(self.finalRequestString == nil){
            __weak RRViewController *weakSelf = self;
            [self prettyJsonString:self.requestContent andCompletionHandler:^(NSString *formatedString) {
                __strong RRViewController *strongSelf = weakSelf;
                strongSelf.finalRequestString = formatedString;
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentTextView.text = self.finalRequestString;
        });
    } else {
        
        if(self.finalResponseString == nil){
            __weak RRViewController *weakSelf = self;
            [self prettyJsonString:self.responseContent andCompletionHandler:^(NSString *formatedString) {
                __strong RRViewController *strongSelf = weakSelf;
                strongSelf.finalResponseString = formatedString;
                
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentTextView.text = self.finalResponseString;
            
        });
    }
    self.contentTextView.selectedRange = NSMakeRange(0, 0);
     //[self performSelector:@selector(disableTextView) withObject:nil afterDelay:3.0];
    
}

-(void) disableTextView {
    [self.contentTextView setEditable:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prettyJsonString:(NSString *)jsonString andCompletionHandler:(void (^)(NSString *formatedString))completionHandler{
    
    NSString *formatString = @"";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject == nil) {
        formatString = jsonString;
    } else {
        NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
            formatString = [[NSString alloc] initWithData:prettyJsonData encoding:NSUTF8StringEncoding];
        
        NSLog(@"DemandServer-Punnaghai2 %@", formatString);
    }
    completionHandler(formatString);
}

@end
