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
    
    self.contentImage.userInteractionEnabled = YES;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;

    
    [self.contentImage addGestureRecognizer:leftSwipe];
    [self.contentImage addGestureRecognizer:rightSwipe];
    
  self.pageControl.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
}

- (void)swipeAction:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    int currentPage = (int)self.pageControl.currentPage;
    if(swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
        
        if(self.pageControl.currentPage != 2){
            currentPage++;
            [self.pageControl setCurrentPage:currentPage];
            
        }
        
    } else if(swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
        if(self.pageControl.currentPage != 0){
            currentPage--;
            
            [self.pageControl setCurrentPage:currentPage];
            
        }
    }
    [self setPageContent:(int)self.pageControl.currentPage];
}

- (IBAction) skipPressed: (id ) sender
{
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self presentViewController:    [main instantiateInitialViewController] animated:YES completion:nil];
}

- (IBAction) pageChanged:(id)sender {
    int i = (int)self.pageControl.currentPage;
    [self setPageContent:i];
}

- (void) setPageContent:(int) pageNumber {
    if (pageNumber == 0) {
        self.contentImage.image = [UIImage imageNamed:@"intro1Image"];
        
    } else if (pageNumber == 1) {
        self.contentImage.image = [UIImage imageNamed:@"intro2Image"];
        
    } else if (pageNumber == 2) {
        self.contentImage.image = [UIImage imageNamed:@"intro3Image"];
        
    }
}
@end
