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

@interface RRViewController ()

@property (nonatomic, strong) NSString *finalRequestString;
@property (nonatomic, strong) NSString *finalResponseString;
@end

@implementation RRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Bid Request/Response";
    
    [self.segmentControl setSelectedSegmentIndex:0];
    
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
    
    self.contentTextView.text = self.finalRequestString;
    
}

-(void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)segmentChanged:(id)sender {
    NSInteger selectedIndex = [self.segmentControl selectedSegmentIndex];
    self.contentTextView.text = @"";
    [self.contentTextView setContentOffset:CGPointZero animated:NO];
    if(selectedIndex == 0){
        if(self.finalRequestString == nil){
            __weak RRViewController *weakSelf = self;
            [self prettyJsonString:self.requestContent andCompletionHandler:^(NSString *formatedString) {
                __strong RRViewController *strongSelf = weakSelf;
                strongSelf.finalRequestString = formatedString;
                strongSelf.contentTextView.text = strongSelf.finalRequestString;
            }];
        } else {
            self.contentTextView.text = self.finalRequestString;
        }
    } else {
        
        if(self.finalResponseString == nil){
            __weak RRViewController *weakSelf = self;
            [self prettyJsonString:self.responseContent andCompletionHandler:^(NSString *formatedString) {
                __strong RRViewController *strongSelf = weakSelf;
                strongSelf.finalResponseString = formatedString;
                strongSelf.contentTextView.text = strongSelf.finalResponseString;
            }];
        } else {
            self.contentTextView.text = self.finalResponseString;
        }
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

-(void)prettyJsonString:(NSString *)jsonString andCompletionHandler:(void (^)(NSString *formatedString))completionHandler{
    
    NSString *formatString = @"";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (jsonObject == nil) {
        formatString = jsonString;
    } else {
        NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
        formatString = [NSString stringWithUTF8String:[prettyJsonData bytes]];
        
    }
    completionHandler(formatString);
}


@end
