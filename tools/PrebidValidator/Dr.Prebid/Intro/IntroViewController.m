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

#import "IntroViewController.h"
#import "ColorTool.h"
#import "CustomPageControl.h"

@interface IntroViewController()
@end

@implementation IntroViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Welcome to Dr.Prebid";
    self.view.backgroundColor = [UIColor whiteColor];
    // Add Page control
    CustomPageControl *pageControl = [[CustomPageControl alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height - 100)];
    [self.view addSubview:pageControl];
    
    // Add skip button
    UIButton *skip = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 75, self.view.frame.size.width- 40., 50)];
    [skip setTitle:@"Skip" forState:UIControlStateNormal];
    skip.backgroundColor = [ColorTool prebidBlue];
    skip.layer.cornerRadius = 15;
    skip.clipsToBounds = YES;
    [self.view addSubview:skip];
    [skip addTarget:self action:@selector(skipPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) skipPressed: (id ) sender
{
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self presentViewController:    [main instantiateInitialViewController] animated:YES completion:nil];
}
@end
