/*   Copyright 2019-2022 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "BannerBaseViewController.h"

@interface BannerBaseViewController ()

@end

@implementation BannerBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.bannerView.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.firstAttribute == NSLayoutAttributeWidth;
    }]].firstObject.constant = self.adSize.width;
    
    [self.bannerView.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.firstAttribute == NSLayoutAttributeHeight;
    }]].firstObject.constant = self.adSize.height;
}

-(id)init {
    self = [super initWithNibName:@"BannerBaseViewController" bundle:nil];
    self.adSize = CGSizeMake(320, 50);
    return self;
}

-(id)initWithAdSize:(CGSize)adSize {
    self = [super initWithNibName:@"BannerBaseViewController" bundle:nil];
    self.adSize = adSize;
    return self;
}

@end
