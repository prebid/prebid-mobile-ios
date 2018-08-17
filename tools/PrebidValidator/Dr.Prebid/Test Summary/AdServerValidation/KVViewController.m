//
//  KVViewController.m
//  Dr.Prebid
//
//  Created by Punnaghai Puviarasu on 8/17/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import "KVViewController.h"

@interface KVViewController ()

@end

@implementation KVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Key-Value Targeting";
    
    if(self.keyWordsDictionary != nil){
        NSString *dictString = [NSString stringWithFormat:@"%@", self.keyWordsDictionary];
        
        NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
        NSString *requiredString = [[dictString componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];

        self.contentLabel.text = requiredString;
        
        [self.contentLabel sizeToFit];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
