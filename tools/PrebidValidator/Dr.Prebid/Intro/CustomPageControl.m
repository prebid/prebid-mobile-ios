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


#import "CustomPageControl.h"
#import "ColorTool.h"

@interface CustomPageControl()
@property UIImageView *content;
@end

@implementation CustomPageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfPages = 3;
        self.content= [[UIImageView alloc] init];
        _content.image = [UIImage imageNamed:@"intro1Image"];
        _content.frame = CGRectMake(0, 0,375, 509);
        _content.center =self.center;
        [self addSubview:_content];
        [self addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void) pageTurn: (UIPageControl *) page
{
    int i = (int) page.currentPage;
    if (i == 0) {
        _content.image = [UIImage imageNamed:@"intro1Image"];
        _content.center = page.center;
    } else if (i == 1) {
        _content.image = [UIImage imageNamed:@"intro2Image"];
        _content.center = page.center;
    } else if (i == 2) {
        _content.image = [UIImage imageNamed:@"intro3Image"];
        _content.center = page.center;
    }
    [self updateDots];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self updateDots];
}

- (void) updateDots
{
    // Remove old dots
    for (UIView *sub in self.subviews) {
        if (![sub isKindOfClass:[UIImageView class]]) {
            [sub removeFromSuperview];
        }
    }
    // Add new customized dot
    int width = (int) self.numberOfPages * 50;
    UIView *dotContainer = [[UIView alloc] initWithFrame: CGRectMake((self.frame.size.width - width)/2, self.frame.size.height - 50, width, 50)];
    for (int i = 0; i < self.numberOfPages; i ++) {
        UIView *newDot = [[UIView alloc] initWithFrame:CGRectMake(i* 50, 0, 50, 50)];
        UIView *status = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 18, 18)];
        if (i == self.currentPage) {
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
    [self addSubview:dotContainer];
}

@end

