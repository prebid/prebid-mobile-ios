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

@interface IntroViewController()
@end

@implementation IntroViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Welcome to Dr.Prebid";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Add skip button
    self.btnSkip.backgroundColor = [ColorTool prebidBlue];
    self.btnSkip.layer.cornerRadius = 15;
    self.btnSkip.clipsToBounds = YES;
    
    self.contentImage.image = [UIImage imageNamed:@"intro1Image"];
    
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [ColorTool prebidBlue];
    
    
  self.pageControl.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
}

- (IBAction) skipPressed: (id ) sender
{
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self presentViewController:    [main instantiateInitialViewController] animated:YES completion:nil];
}

- (IBAction) pageChanged:(id)sender {
    UIPageControl *page = (UIPageControl *) sender;
    int i = (int) page.currentPage;
    if (i == 0) {
        self.contentImage.image = [UIImage imageNamed:@"intro1Image"];
        
    } else if (i == 1) {
        self.contentImage.image = [UIImage imageNamed:@"intro2Image"];
        
    } else if (i == 2) {
        self.contentImage.image = [UIImage imageNamed:@"intro3Image"];
        
    }
}

- (void) updateDots
{
    // Remove old dots
    for (UIView *sub in self.pageControl.subviews) {
        if (![sub isKindOfClass:[UIImageView class]]) {
            [sub removeFromSuperview];
        }
    }
    // Add new customized dot
    int width = (int) self.pageControl.numberOfPages * 50;
    UIView *dotContainer = [[UIView alloc] initWithFrame: CGRectMake((self.pageControl.frame.size.width - width)/2, self.pageControl.frame.size.height - 50, width, 50)];
    for (int i = 0; i < self.pageControl.numberOfPages; i ++) {
        UIView *newDot = [[UIView alloc] initWithFrame:CGRectMake(i* 50, 0, 50, 50)];
        UIView *status = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 18, 18)];
        if (i == self.pageControl.currentPage) {
            status.backgroundColor  = [ColorTool prebidBlue];
            status.layer.cornerRadius = status.frame.size.height/2;
        } else {
            status.backgroundColor = [UIColor clearColor];
            status.layer.cornerRadius = status.frame.size.height/2;
            status.layer.borderColor = [[ColorTool prebidOrange] CGColor];
            status.layer.borderWidth = 2;
        }
        [newDot addSubview:status];
        [dotContainer addSubview:newDot];
    }
    [self.pageControl addSubview:dotContainer];
}
@end
