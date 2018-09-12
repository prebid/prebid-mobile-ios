//
//  IntroViewController.m
//  Dr.Prebid
//
//  Created by Wei Zhang on 9/12/18.
//  Copyright © 2018 Prebid. All rights reserved.
//

#import "IntroViewController.h"
#import "ColorTool.h"

@interface IntroViewController()
@end

@implementation IntroViewController
- (void)viewDidLoad
{
    self.title = @"Welcome to Dr.Prebid";
    self.view.backgroundColor = [UIColor whiteColor];
    // Add Page control
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height - 100);
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    UIImageView *cat1 = [[UIImageView alloc] init];
    cat1.image = [UIImage imageNamed:@"cat1"];
    cat1.frame = CGRectMake(0, 0,250, 308);
    cat1.center = pageControl.center;
    [pageControl addSubview:cat1];
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
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

- (void)pageTurn: (UIPageControl *) page
{
    for (UIView *sub in page.subviews) {
        [sub removeFromSuperview];
    }
    int i = (int) page.currentPage;
    if (i == 0) {
        UIImageView *cat1 = [[UIImageView alloc] init];
        cat1.image = [UIImage imageNamed:@"cat1"];
        cat1.frame = CGRectMake(0, 0,250, 308);
        cat1.center = page.center;
        [page addSubview:cat1];
    } else if (i == 1) {
        UIImageView *cat2 = [[UIImageView alloc] init];
        cat2.image = [UIImage imageNamed:@"cat2"];
        cat2.frame = CGRectMake(0, 0,250, 250);
        cat2.center = page.center;
        [page addSubview:cat2];
    }
}
@end
